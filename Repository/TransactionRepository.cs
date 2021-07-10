using AKStore.Entity;
using AKStore.Extension;
using AKStore.Models;
using Dapper;
using System;
using System.Collections.Generic;
using System.Linq;

namespace AKStore.Repository
{
    public class TransactionRepository : BaseRepository<TransactionMaster>, ITransactionRepository
    {

        public Tuple<bool, string> UpsertTransaction(TransactionMaster transaction)
        {
            var message = string.Empty;
            var success = false;
            var p = new DynamicParameters();
            p.Add("@Id", transaction.Id);
            p.Add("@RetailerDetailsId", transaction.RetailerDetailsId);
            p.Add("@CustomerId", transaction.CustomerId);
            p.Add("@Amount", transaction.Amount);
            p.Add("@Notes", transaction.Notes);
            p.Add("@TransactionDate", transaction.TransactionDate);
            p.Add("@InsertedByUserId", transaction.InsertedByUserId);
            p.Add("@UpdatedByUserId", transaction.UpdatedByUserId);
            var result = CommonOperations.Query<int>("UpsertTransaction", p, commandType: System.Data.CommandType.StoredProcedure).FirstOrDefault();
            if (result == 0)
            {
                message = "Transation added successfully";
                success = true;
            }
            else if (result == 1)
            {
                message = "Transation updated successfully";
                success = true;
            }
            else
            {
                message = "Something went wrong";
                success = false;
            }

            return new Tuple<bool, string>(success, message);
        }

        public Tuple<bool, string> DeleteTransaction(int transactionId)
        {
            var message = string.Empty;
            var success = false;
            var p = new DynamicParameters();
            p.Add("@Id", transactionId);
            p.Add("@TableName", "TransactionMaster");
            var msg = CommonOperations.Query<string>("DeleteById", p, commandType: System.Data.CommandType.StoredProcedure).FirstOrDefault();
            if (msg == null)
            {
                message = "Transaction deleted successfully.";
                success = true;
            }
            else
            {
                message = "Transaction not found.";
                success = false;
            }

            return new Tuple<bool, string>(success, message);
        }
        public IEnumerable<TransactionModel> GetTransaction(int retailerId, int customerId, DateTime? fromDate, DateTime? toDate)
        {
            var p = new DynamicParameters();
            p.Add("@retailerId", retailerId);
            p.Add("@customerId", customerId);
            p.Add("@fromDate", fromDate);
            p.Add("@toDate", toDate);
            var transactionModels = CommonOperations.Query<TransactionModel>("GetTransaction", p, commandType: System.Data.CommandType.StoredProcedure).ToList();
            return transactionModels;
        }
        public TransactionModel GetTransactionById(int id)
        {
            var p = new DynamicParameters();
            p.Add("@id", id);
            var transactionModels = CommonOperations.Query<TransactionModel>("GetTransactionById", p, commandType: System.Data.CommandType.StoredProcedure).FirstOrDefault();
            return transactionModels;
        }


        public IEnumerable<TransactionReportModel> GetTransactionReport(int retailerId, int customerId, DateTime? fromDate, DateTime? toDate)
        {
            var p = new DynamicParameters();
            p.Add("@RetailerId", retailerId);
            p.Add("@CustomerId", customerId);
            p.Add("@FromDate", fromDate);
            p.Add("@ToDate", toDate);
            var transactionModels = CommonOperations.Query<TransactionReportModel>("GetTransactionReport", p, commandType: System.Data.CommandType.StoredProcedure).ToList();
            return transactionModels;
        }
    }
}
