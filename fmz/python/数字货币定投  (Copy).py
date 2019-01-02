def onTick():
	
	exchange_count = len(exchanges)
	for i in range(exchange_count):
		account = exchanges[i].GetAccount()

		marketName = exchanges[i].GetName()
		depth = exchanges[i].GetDepth()
		Log("Market ",marketName,exchanges[i].GetCurrency(),"Account Balance [",account["Balance"],"] Stocks[",account["Stocks"],"]")
		if account and depth and account["Balance"] > accountLimitMoney :
			bidPrice = depth["Asks"][0]["Price"] 
			if bidPrice <  maxBidPrice :
				amount = orderAmount
				if amount <= account["Balance"]:
					exchanges[i].Buy(amount)
				else:
					Log("Account Balance is less than bid Amount")
			else:
				Log("Bid Price >= maxBidPrice, not process")
		else:
			Log("Account Balance <= accountLimitMoney")
def main() :
	while 1:
		
		onTick()
		time.sleep(orderTimeInterval)