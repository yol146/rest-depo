import datetime
import time
class BankAccount:
    def __init__(self):
        self.checking_account = 0.0
        self.savings_account = 0.0
        self.transactions = {}

    def statement(self, action_type, amount, account_type):
        timestamp = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        self.transactions[timestamp] = (action_type, amount, account_type)

    def deposit(self, amount, account_type):
        time.sleep(1);
        if account_type == 'checking':
            self.checking_account += amount
        elif account_type == 'savings':
            self.savings_account += amount
        self.statement("Deposit", amount, account_type)

    def withdraw(self, amount, account_type):
        time.sleep(1);
        if account_type == 'checking' and amount <= self.checking_account:
            self.checking_account -= amount
        elif account_type == 'savings' and amount <= self.savings_account:
            self.savings_account -= amount
        else:
            return "Insufficient funds!"
        self.statement("withdraw", amount, account_type)

    def transfer(self, amount, acount1, to_account):
        time.sleep(1);
        if acount1 == 'checking' and amount <= self.checking_account:
            self.withdraw(amount, acount1)
            self.deposit(amount, to_account)
        elif acount1 == 'savings' and amount <= self.savings_account:
            self.withdraw(amount, acount1)
            self.deposit(amount, to_account)
        else:
            return "Insufficient funds!"
        
    def display(self):
        for timestamp, transaction in self.transactions.items():
            print(f"{timestamp}: {transaction[0]}  ${transaction[1]} {transaction[2]}  ")

account = BankAccount()
account.deposit( 1000,'checking')
account.deposit(500,'savings')
account.transfer(500,'checking', 'savings')
account.deposit( 250,'checking')
account.withdraw( 500,'savings')
account.display()