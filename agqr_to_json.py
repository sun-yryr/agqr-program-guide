#coding: UTF-8
import requests
import json
import datetime
from bs4 import BeautifulSoup
import time

def main():
    body = get_html()
    #body = test()
    soup = BeautifulSoup(body, "html.parser")
    table_body = soup.find("table").find("tbody")
    if table_body is None:
        return
    new_table = create_table(table_body)
    f = open("agqr_table.json", "w")
    json.dump(new_table, f, ensure_ascii=False)
    f.close()


    not_repeat = []
    for i in range(7):
        not_repeat.append([])
    for i in range(len(new_table)):
        for prog in new_table[i]:
            if prog.get("isRepeat") == False:
                not_repeat[i].append(prog)
    f = open("agqr_table_not_repeat.json", "w")
    json.dump(not_repeat, f, ensure_ascii=False)
    f.close
    

def create_table(table):
    # 月曜の日付（基準）を取得する
    today = datetime.date.today()
    monday = (today - datetime.timedelta(days=today.weekday())).strftime("%Y%m%d")
    # 切り替えの基準を作る
    criterion = datetime.datetime.strptime("06:00", "%H:%M")
    end_times = [datetime.datetime.strptime("06:00", "%H:%M")] * 7
    main_data = []
    main_data2 = []
    for i in range(7):
        main_data.append([])
        main_data2.append([])
    for tr in table.find_all("tr"):
        td_all = tr.find_all("td")
        if (td_all is None) or (len(td_all) == 0):
            continue
        for i in range(len(td_all)):
            td = td_all[i]
            # time が24時を超えた場合のアレ
            time_str = td.find(class_="time").text.replace("\n", "").replace(" 頃", "").split(":")
            if int(time_str[0]) >= 24:
                time_str[0] = format(int(time_str[0]) - 24,  "02")
            time_str = time_str[0] + time_str[1]
            # datetime にする
            tmp_dt = datetime.datetime.strptime(time_str, "%H%M")

            i2 = i
            while(i2<7):
                title = td.find(class_="title-p").text.replace("\n", "").replace("\u3000", " ")
                pfm = td.find(class_="rp").text.replace("\n", "")
                c = td.get("class")[0]
                isBroadcast = True
                if c == "bg-repeat":
                    # これは再放送
                    isRepeat = True
                elif c == "bg-f" or c == "bg-l":
                    isRepeat = False
                else:
                    isBroadcast = False
                # end_time が1900/1/2になったら分岐する
                if tmp_dt < criterion:
                    tmp_dt2 = tmp_dt + datetime.timedelta(days=1)
                    new_i = (i2 + 1) % 7
                    if tmp_dt2 == end_times[new_i]:
                        # endtime を更新
                        end_times[new_i] += datetime.timedelta(minutes=int(td.get("rowspan")))
                        ft = datetime.datetime.strptime(monday + time_str, "%Y%m%d%H%M") + datetime.timedelta(days=new_i)
                        to = ft + datetime.timedelta(minutes=int(td.get("rowspan")))
                        new_data = {
                            "title": title,
                            "ft": ft.strftime("%Y%m%d%H%M"),
                            "to": to.strftime("%Y%m%d%H%M"),
                            "pfm": pfm,
			                "dur": int(td.get("rowspan")),
                            "isBroadcast": isBroadcast
                        }
                        if isBroadcast:
                            new_data["isRepeat"] = isRepeat
                        main_data[new_i].append(new_data)
                        break
                else:
                    if tmp_dt == end_times[i2]:
                        # endtime を更新
                        # ほんまアニメージュ許さんからな
                        if title == "ラジオアニメージュ":
                            end_times[i2] += datetime.timedelta(minutes=30)
                        else:
                            end_times[i2] += datetime.timedelta(minutes=int(td.get("rowspan")))
                        ft = datetime.datetime.strptime(monday + time_str, "%Y%m%d%H%M") + datetime.timedelta(days=i2)
                        to = ft + datetime.timedelta(minutes=int(td.get("rowspan")))
                        new_data = {
                            "title": title,
                            "ft": ft.strftime("%Y%m%d%H%M"),
                            "to": to.strftime("%Y%m%d%H%M"),
                            "pfm": pfm,
			                "dur": int(td.get("rowspan")),
                            "isBroadcast": isBroadcast
                        }
                        if isBroadcast:
                            new_data["isRepeat"] = isRepeat
                        main_data2[i2].append(new_data)
                        break
                i2 += 1
                if i2 == 7:
                    # 追加できなかった番組
                    print(td.find(class_="title-p").text.replace("\n", ""), ft.strftime("%Y%m%d%H%M"), time_str)
    for i in range(7):
        main_data[i].extend(main_data2[i])
    return main_data
            

def get_html():
    res = requests.get("https://www.agqr.jp/timetable/streaming.html")
    res.encoding = "utf-8"
    return res.text

def test():
    html = open("agqr.html", "r")
    return html.read()

if __name__ == "__main__":
    main()
    
