using AKStore.Extension;
using AKStore.Filters;
using AKStore.Models;
using AKStore.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace AKStore.Controllers
{
    [CustomAuthorize(Role.Distributor)]
    public class TransactionController : Controller
    {
        private ITransactionService _transactionService;
        private ICustomerService _customerService;
        public TransactionController()
        {
            _customerService = new CustomerService();
            _transactionService = new TransactionService();
        }
        public ActionResult Transaction()
        {
            return View();
        }

        [HttpPost]
        public ActionResult GetTransactionData(int customerId, DateTime? fromDate, DateTime? toDate)
        {
            try
            {
                var distributorId = Convert.ToInt32(Session["DistributorId"]);
                var transactions = _transactionService.GetTransaction(distributorId, customerId, fromDate, toDate).ToList();
                return Json(new { Data = transactions, Success = true, Message = "Transaction fetched successfully." });
            }
            catch (Exception ex)
            {
                return Json(new { Data = new List<TransactionModel>(), Success = false, Message = ex.Message });
            }
        }

        [HttpGet]
        public ActionResult GetCustomers()
        {
            try
            {
                var DistributorId = Convert.ToInt32(Session["DistributorId"]);
                var customers = _customerService.GetCustomerData(DistributorId);
                return Json(new { customers = customers, Success = true, Message = "Filters data fetched successfully." }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { Success = false, Message = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpGet]
        public ActionResult UpsertTransaction(int? id)
        {
            ViewBag.TransactionId = id;
            return View();
        }

        [HttpGet]
        public ActionResult GetTransactionData(int? id)
        {
            try
            {
                var DistributorId = Convert.ToInt32(Session["DistributorId"]);
                var customers = _customerService.GetCustomerData(DistributorId);
                TransactionModel transactionModel = new TransactionModel();
                if (id != null && id > 0)
                {
                    transactionModel = _transactionService.GetTransactionById(Convert.ToInt32(id));
                }
                return Json(new { customers = customers, transaction = transactionModel, Success = true, Message = "Filters data fetched successfully." }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { Data = new TransactionModel(), Success = false, Message = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }
        [HttpPost]
        public ActionResult UpsertTransaction(TransactionModel transactionModel)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    var tuple = _transactionService.UpsertTransaction(transactionModel);
                    return Json(new { Success = tuple.Item1, Message = tuple.Item2 });
                }
                else
                {
                    return Json(new { Success = false, Message = "Please enter required fields." });
                }
            }
            catch (Exception ex)
            {
                return Json(new { Success = false, Message = ex.Message });
            }

        }


        [HttpPost]
        public ActionResult DeleteTransaction(int id)
        {
            try
            {
                if (id <= 0)
                    return RedirectToAction(nameof(Transaction));

                var tuple = _transactionService.DeleteTransaction(id);
                return RedirectToAction(nameof(Transaction));
            }
            catch (Exception ex)
            {
                return Json(new { Success = false, Message = ex.Message });
            }
        }


        [HttpGet]
        public ActionResult TransactionReport()
        {
            return View();
        }
        public ActionResult GetTransactionReport(int customerId, DateTime? fromDate, DateTime? toDate)
        {
            try
            {
                var DistributorId = Convert.ToInt32(Session["DistributorId"]);
                var transactions = _transactionService.GetTransactionReport(DistributorId, customerId, fromDate, toDate).ToList();
                return Json(new { Data = transactions, Success = true, Message = "Transaction fetched successfully." });
            }
            catch (Exception ex)
            {
                return Json(new { Data = new List<TransactionModel>(), Success = false, Message = ex.Message });
            }
        }

    }
}