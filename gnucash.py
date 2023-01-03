from datetime import datetime
import math
import os
import sqlite3
import uuid


class Account(object):
    def __init__(self):
        self.childs = []
        self.parent = None
        self.name = ""
        self.splits = []
        self.type = None

    def __str__(self):
        return self.name


class Commodity(object):
    def __init__(self):
        self.fullname = ""
        self.mnemonic = ""
        self.namespace = ""
        self.precision = 2
        self.quote_flag = False
        self.quote_source = ""
        self.prices = []

    def __str__(self):
        return self.mnemonic


class Transaction(object):
    def __init__(self):
        self.splits = []


class Split(object):
    def __init__(self):
        pass


class Price(object):
    def __init__(self):
        pass


class GnuCashData(object):
    def __init__(self):
        self.accounts = dict()
        self.commodities = dict()
        self.transactions = dict()
        self.splits = dict()
        self.prices = dict()


def get(objdict, constructor, guid):
    obj = objdict.get(guid)
    if obj is None:
        obj = constructor()
        obj.guid = guid
        objdict[guid] = obj
    return obj


def get_account(data, guid):
    return get(data.accounts, Account, guid)


def get_commodity(data, guid):
    return get(data.commodities, Commodity, guid)


def get_transaction(data, guid):
    return get(data.transactions, Transaction, guid)


def get_split(data, guid):
    return get(data.splits, Split, guid)


def get_price(data, guid):
    return get(data.prices, Price, guid)


def open_file(filename):
    if not os.path.isfile(filename):
        raise Exception("File '%s' does not exist" % filename)
    return sqlite3.connect(filename)


def read_data(connection):
    c = connection.cursor()

    data = GnuCashData()
    for row in c.execute('SELECT guid, namespace, mnemonic, fullname, '
                         'fraction, quote_flag, quote_source '
                         'FROM commodities'):
        guid, namespace, mnemonic, fullname, fraction, quote_flag, \
            quote_source = row
        comm = get_commodity(data, guid)
        comm.namespace = namespace
        comm.mnemonic = mnemonic
        comm.fullname = fullname
        comm.quote_flag = (quote_flag != 0)
        comm.quote_source = quote_source
        comm.precision = int(math.log10(fraction))

    for row in c.execute('SELECT guid, name, account_type, commodity_guid, '
                         'commodity_scu, non_std_scu, parent_guid, code, '
                         'description FROM accounts'):
        guid, name, account_type, commodity_guid, commodity_scu, non_std_scu, \
            parent_guid, code, description = row
        acc = get_account(data, guid)
        acc.name = name
        acc.parent = get_account(data, parent_guid)
        acc.parent.childs.append(acc)
        acc.description = description
        acc.commodity = get_commodity(data, commodity_guid)
        acc.type = account_type

    def parse_time(time):
        try:
            # try gnucash 3 format
            return datetime.strptime(time, '%Y-%m-%d %H:%M:%S')
        except:
            return datetime.strptime(time, "%Y%m%d%H%M%S")

    for row in c.execute('SELECT guid, currency_guid, num, post_date, '
                         'description FROM transactions'):
        guid, currency_guid, num, post_date, description = row
        trans = get_transaction(data, guid)
        trans.currency = get_commodity(data, currency_guid)
        trans.num = num
        trans.post_date = parse_time(post_date)
        trans.description = description

    for row in c.execute('SELECT guid, tx_guid, account_guid, memo, '
                         'value_num, value_denom, quantity_num, '
                         'quantity_denom FROM splits'):
        guid, tx_guid, account_guid, memo, value_num, value_denom, \
            quantity_num, quantity_denom = row
        split = get_split(data, guid)
        split.transaction = get_transaction(data, tx_guid)
        split.transaction.splits.append(split)
        split.account = get_account(data, account_guid)
        split.account.splits.append(split)
        split.value_num = int(value_num)
        split.value_denom = int(value_denom)
        split.value = float(value_num)/float(value_denom)
        split.quantity_num = int(quantity_num)
        split.quantity_denom = int(quantity_denom)
        split.quantity = float(quantity_num)/float(quantity_denom)
        split.memo = memo

    for row in c.execute('SELECT guid, commodity_guid, currency_guid, date, '
                         'value_num, value_denom FROM prices'):
        guid, commodity_guid, currency_guid, date, value_num, value_denom = row
        price = get_price(data, guid)
        price.commodity = get_commodity(data, commodity_guid)
        price.commodity.prices.append(price)
        price.currency = get_commodity(data, currency_guid)
        price.date = parse_time(date)
        price.value_num = int(value_num)
        price.value_denom = int(value_denom)
        if int(value_denom) == 0:
            price.value = 0.0
        else:
            price.value = float(value_num)/float(value_denom)

    # Sort price lists for each commodity
    for commodity in data.commodities.values():
        prices = commodity.prices
        prices.sort(key=lambda price: price.date)

    return data


def read_file(filename):
    conn = open_file(filename)
    return read_data(conn)


# Functions to change data


def change_split_account(connection, split_guid, oldaccount_guid,
                         newaccount_guid):
    connection.execute('UPDATE splits SET account_guid=? WHERE guid=? '
                       'AND account_guid=?',
                       (newaccount_guid, split_guid, oldaccount_guid))
    connection.commit()


def _print_time(time):
    return datetime.strftime(time, "%Y%m%d%H%M%S")


def add_price(connection, commodity_guid, currency_guid, date, source, type,
              value_num, value_denom):
    guid = uuid.uuid4().hex
    date_f = _print_time(date)
    connection.execute('INSERT INTO prices(guid, commodity_guid, '
                       'currency_guid, date, source, type, value_num, '
                       'value_denom) VALUES (?,?,?,?,?,?,?,?)',
                       (guid, commodity_guid, currency_guid, date_f, source,
                        type, value_num, value_denom))
    connection.commit()
    return guid
