import falcon
import json
import datetime

all_json = []
not_repeat_json = []

class AgqrAll:
    def on_get(self, req, resp):
        params = req.params
        isRepeat = params.get("isRepeat")
        if isRepeat is None:
            resp.body = json.dumps(not_repeat_json, ensure_ascii=False)
        elif (isRepeat == "True") or (isRepeat == "true"):
            resp.body = json.dumps(all_json, ensure_ascii=False)
        else:
            resp.body = json.dumps(not_repeat_json, ensure_ascii=False)

class AgqrToday:
    def on_get(self, req, resp):
        week = datetime.date.today().weekday()
        params = req.params
        isRepeat = params.get("isRepeat")
        if isRepeat is None:
            resp.body = json.dumps(not_repeat_json[week], ensure_ascii=False)
        elif (isRepeat == "True") or (isRepeat == "true"):
            resp.body = json.dumps(all_json[week], ensure_ascii=False)
        else:
            resp.body = json.dumps(not_repeat_json[week], ensure_ascii=False)

class AgqrNow:
    def on_get(self, req, resp):
        now = datetime.datetime.now()
        week = now.weekday()
        res = all_json[week]
        for i in range(len(res)):
            prog = res[i]
            tmp_dt = datetime.datetime.strptime(prog["to"], "%Y%m%d%H%M")
            if now < tmp_dt:
                resp.body = json.dumps(prog, ensure_ascii=False)
                break

class reload:
    def on_get(self, req, resp):
        loadfile()
        resp.body = "ok"

app = falcon.API()
app.add_route('/api/all', AgqrAll())
app.add_route('/api/today', AgqrToday())
app.add_route('/api/now', AgqrNow())
app.add_route('/api/reload', reload())

def loadfile():
    global all_json
    global not_repeat_json
    f = open("create_table.json", "r")
    all_json = json.loads(f.read(), encoding="utf-8")
    f.close()
    f = open("create_table2.json", "r")
    not_repeat_json = json.loads(f.read(), encoding="utf-8")
    f.close()

if __name__ == "__main__":
    loadfile()
    from wsgiref import simple_server
    httpd = simple_server.make_server("127.0.0.1", 1234, app)
    httpd.serve_forever()
