using AKStore.Models;
using System;
using System.Collections.Generic;

namespace AKStore.Services
{
    public interface ITransactionService
    {
        IEnumerable<TransactionModel> GetTransaction(int retailerId, int customerId, DateTime? fromDate, DateTime? toDate);

        Tuple<bool, string> UpsertTransaction(TransactionModel transactionModel);
        Tuple<bool, string> DeleteTransaction(int id);
        TransactionModel GetTransactionById(int id);
        IEnumerable<TransactionReportModel> GetTransactionReport(int retailerId, int customerId, DateTime? fromDate, DateTime? toDate);
    }
}
