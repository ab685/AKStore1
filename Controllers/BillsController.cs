using AKStore.Extension;
using AKStore.Filters;
using AKStore.Models;
using AKStore.Services;
using Rotativa;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace AKStore.Controllers
{
    [CustomAuthorize(Role.Distributor)]
    public class BillsController : Controller
    {
        private readonly IOrderService _orderService;
        public BillsController()
        {
            _orderService = new OrderService();
        }
        // GET: Bill
        public ActionResult Bills(List<int> selectedIds)
        {
            BillsViewModel billsViewModel = new BillsViewModel();
            return View(billsViewModel);
        }
        public ActionResult BillsPDF(List<int> selectedIds)
        {
            if (selectedIds.Count() <= 0)
                return new HttpNotFoundResult("Not found record");

            BillsViewModel billsViewModel = new BillsViewModel();
            billsViewModel.BillDate = DateTime.Now;
            var random = new Random();
            billsViewModel.DeliveryNote = "DN-" + random.Next(5000, int.MaxValue);

            var billsItemModels = _orderService.GetOrderBillsData(selectedIds);
            billsViewModel.NetAmount = billsItemModels.Sum(x => (x.Price * x.Quantity));
            billsViewModel.StoreName = billsItemModels.FirstOrDefault()?.StoreName;
            billsViewModel.CustomerName = billsItemModels.FirstOrDefault()?.CustomerName;
            billsViewModel.Address = billsItemModels.FirstOrDefault()?.Address;
            billsViewModel.PostalCode = billsItemModels.FirstOrDefault()?.PostalCode;
            billsViewModel.DistributorName = billsItemModels.FirstOrDefault()?.DistributorName;

            billsViewModel.BillsItemModels = billsItemModels;
            var report = new ViewAsPdf("Bills", billsViewModel);
            report.FileName = "Bill_" + DateTime.Now.ToString() + ".pdf";
            return report;
        }
    }
}