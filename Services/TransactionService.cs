using AKStore.Entity;
using AKStore.Models;
using AKStore.Repository;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace AKStore.Services
{
    public class TransactionService : BaseService, ITransactionService
    {
        private readonly ITransactionRepository _transactionRepository;
       
        public TransactionService() : base()
        {
            _transactionRepository = new TransactionRepository();
           
        }

        public IEnumerable<TransactionModel> GetTransaction(int distributorId, int customerId, DateTime? fromDate, DateTime? toDate)
        {
            var transactionModels = _transactionRepository.GetTransaction(distributorId, customerId, fromDate, toDate);
            return transactionModels;
        }
        public TransactionModel GetTransactionById(int id)
        {
            var transactionModel = _transactionRepository.GetTransactionById(id);
            return transactionModel;
        }

        public Tuple<bool, string> UpsertTransaction(TransactionModel transactionModel)
        {
            var LoggedInUserId = Convert.ToInt32(HttpContext.Current.Session["LoggedInUserId"]);
            //var retailerDetails = _retailerDetailsRepository.GetAll(x => x.UserId == LoggedInUserId).FirstOrDefault();

            var transaction = AutoMapper.Mapper.Map<TransactionMaster>(transactionModel);
           // transaction.RetailerDetailsId = retailerDetails.Id;
            transaction.InsertedByUserId = LoggedInUserId;
            transaction.UpdatedByUserId = LoggedInUserId;
            transaction.DistributorId= Convert.ToInt32(HttpContext.Current.Session["DistributorId"]);
            return _transactionRepository.UpsertTransaction(transaction);
        }
        public Tuple<bool, string> DeleteTransaction(int id)
        {
            return _transactionRepository.DeleteTransaction(id);
        }

        public IEnumerable<TransactionReportModel> GetTransactionReport(int distributorId, int customerId, DateTime? fromDate, DateTime? toDate)
        {
            var transactionModels = _transactionRepository.GetTransactionReport(distributorId, customerId, fromDate, toDate);
            return transactionModels;
        }

    }
}
