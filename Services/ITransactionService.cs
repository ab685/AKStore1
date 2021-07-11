using AKStore.Models;
using System;
using System.Collections.Generic;

namespace AKStore.Services
{
    public interface ITransactionService
    {
        IEnumerable<TransactionModel> GetTransaction(int distributorId, int customerId, DateTime? fromDate, DateTime? toDate);

        Tuple<bool, string> UpsertTransaction(TransactionModel transactionModel);
        Tuple<bool, string> DeleteTransaction(int id);
        TransactionModel GetTransactionById(int id);
        IEnumerable<TransactionReportModel> GetTransactionReport(int distributorId, int customerId, DateTime? fromDate, DateTime? toDate);
    }
}
