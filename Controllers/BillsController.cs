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
            billsViewModel.BalanceToDate = 236.60m;
            billsViewModel.BillHeading = "Safasha ERP-Delivery Note Reciept";
            billsViewModel.Title = "Customer Delivery Note";
            billsViewModel.shippingAmount = 0;
            billsViewModel.Discount = 0;

            //billsViewModel.PreviousBalance = 147.10m;
            billsViewModel.BillDate = DateTime.Now;
            billsViewModel.Cashier = "Y2-POS5";
            billsViewModel.DeliveryNote = "DN-43486";
            billsViewModel.DeliveryAddress = "WEMBLEY HIGH STREET London UK 0 UK";
            var billsItemModels = _orderService.GetOrderBillsData(selectedIds);
            billsViewModel.SubTotal = billsItemModels.Sum(x => (x.Price * x.Quantity));
            billsViewModel.NetAmount = Convert.ToDecimal(billsViewModel.SubTotal) - Convert.ToDecimal(billsViewModel.Discount) + Convert.ToDecimal(billsViewModel.shippingAmount);
            billsViewModel.StoreName = billsItemModels.FirstOrDefault()?.StoreName;
            billsViewModel.BillsItemModels = billsItemModels;
            var report = new ViewAsPdf("Bills", billsViewModel);
            report.FileName = "Bill_" + DateTime.Now.ToString() + ".pdf";
            return report;
        }
    }
}