'''
/*backtest
start: 2016-01-30        
end: 2016-12-30           
period: 1440
periodBase: 60
mode: 0                 
*/
'''

class Trader:
    def __init__(self, q, symbol):
        self.q = q
        self.symbol = symbol
        self.position = 0
        self.isPending = False

    def onOpen(self, task, ret):
        if ret:
            self.position = ret['position']['Amount'] * (1 if (ret['position']['Type'] == PD_LONG or ret['position']['Type'] == PD_LONG_YD) else -1)
        Log(task["desc"], "Position:", self.position, ret)
        self.isPending = False

    def onCover(self, task, ret):
        self.isPending = False
        self.position = 0
        Log(task["desc"], ret)

    def onTick(self):
        if self.isPending:
            return
        ct = exchange.SetContractType(self.symbol)
        if not ct:
            return

        r = exchange.GetRecords()
        if not r or len(r) < 35:
            return
        macd = TA.MACD(r)
        
        diff = macd[0][-2] - macd[1][-2]
        if abs(diff) > 0 and self.position == 0:
            self.isPending = True
            self.q.pushTask(exchange, self.symbol, ("buy" if diff > 0 else "sell"), 1, self.onOpen)
        if abs(diff) > 0 and ((diff > 0 and self.position < 0) or (diff < 0 and self.position > 0)):
            self.isPending = True
            self.q.pushTask(exchange, self.symbol, ("closebuy" if self.position > 0 else "closesell"), 1, self.onCover)

def main():
    q = ext.NewTaskQueue()
    Log(_C(exchange.GetAccount))
    tasks = []
    for symbol in ContractList.split(','):
        tasks.append(Trader(q, symbol.strip()))
    while True:
        if exchange.IO("status"):
            for t in tasks:
                t.onTick()
            q.poll()
            Sleep(1000)