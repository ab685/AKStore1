using AKStore.Entity;
using AKStore.Models;
using System;
using System.Collections.Generic;

namespace AKStore.Repository
{
    public interface ITransactionRepository : IBaseRepository<TransactionMaster>
    {
        Tuple<bool, string> UpsertTransaction(TransactionMaster transaction);
        Tuple<bool, string> DeleteTransaction(int transactionId);
        IEnumerable<TransactionModel> GetTransaction(int retailerId, int customerId, DateTime? fromDate, DateTime? toDate);
        IEnumerable<TransactionReportModel> GetTransactionReport(int retailerId, int customerId, DateTime? fromDate, DateTime? toDate);
        TransactionModel GetTransactionById(int id);
    }
}
