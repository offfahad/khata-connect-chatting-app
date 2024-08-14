import 'package:flutter_notifications/database/transactionDao.dart';

import '../models/transaction.dart';

class TransactionRepository {
  final transactionDao = TransactionDao();

  Future getAllTransactions({String? query}) =>
      transactionDao.getTransactions(query: query);

  Future getTransaction(int id) => transactionDao.getTransaction(id);

  Future getCustomerTransactionsTotal(int id) =>
      transactionDao.getCustomerTransactionsTotal(id);

  Future<double> getTotalGivenToCustomers(int businessId) {
    return transactionDao.getTotalGivenToCustomers(businessId);
  }

  Future<double> getTotalToReceiveFromCustomers(int businessId) {
    return transactionDao.getTotalToReceiveFromCustomers(businessId);
  }

  Future<double> getBusinessTransactionsTotal(int id) =>
      transactionDao.getBusinessTransactionsTotal(id);

  Future getAllTransactionsByCustomerId(int cid) =>
      transactionDao.getTransactionsByCustomerId(cid);

  Future insertTransaction(Transaction transaction) =>
      transactionDao.createTransaction(transaction);

  Future updateTransaction(Transaction transaction) =>
      transactionDao.updateTransaction(transaction);

  Future deleteTransactionById(int id) => transactionDao.deleteTransaction(id);
}
