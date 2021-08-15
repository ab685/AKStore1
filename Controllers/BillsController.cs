using AKStore.Extension;
using AKStore.Filters;
using AKStore.Models;
using AKStore.Services;
using SelectPdf;
using System;
using System.Collections.Generic;
using System.IO;
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
        [CustomAuthorize(Role.Distributor, Role.Customer)]
        public ActionResult Bills(List<int> selectedIds)
        {
            BillsViewModel billsViewModel = new BillsViewModel();
            return View(billsViewModel);
        }

        [CustomAuthorize(Role.Distributor)]
        public ActionResult BillsPDF(List<int> selectedIds)
        {
            if (selectedIds.Count() <= 0)
                return new HttpNotFoundResult("Not found record");

            BillsViewModel billsViewModel = new BillsViewModel();
            var BritishZone = TimeZoneInfo.FindSystemTimeZoneById("GMT Standard Time");

            DateTime dt = DateTime.SpecifyKind(DateTime.UtcNow, DateTimeKind.Unspecified);

            DateTime DateTimeInBritishLocal = TimeZoneInfo.ConvertTime(dt, TimeZoneInfo.Utc, BritishZone);
            billsViewModel.BillDate = DateTimeInBritishLocal;
            var random = new Random();
            
            var billsItemModels = _orderService.GetOrderBillsData(selectedIds);
            billsViewModel.NetAmount = billsItemModels.Sum(x => (x.Price * x.Quantity));
            billsViewModel.StoreName = billsItemModels.FirstOrDefault()?.StoreName;
            billsViewModel.CustomerName = billsItemModels.FirstOrDefault()?.CustomerName;
            billsViewModel.CustomerId = billsItemModels.FirstOrDefault()?.CustomerId;
            billsViewModel.Address = billsItemModels.FirstOrDefault()?.Address;
            billsViewModel.PostalCode = billsItemModels.FirstOrDefault()?.PostalCode;
            billsViewModel.DistributorName = billsItemModels.FirstOrDefault()?.DistributorName;
            billsViewModel.DistributorId = billsItemModels.FirstOrDefault()?.DistributorId;
            billsViewModel.BillNo = billsItemModels.FirstOrDefault()?.BillNo ?? 5000;

            billsViewModel.BillsItemModels = billsItemModels;
            _orderService.InsertBillsData(billsViewModel);
            //var report = new ViewAsPdf("Bills", billsViewModel);
            //report.FileName = "Bill_" + DateTime.Now.ToString() + ".pdf";
            // return report;

            HtmlToPdf converter = new HtmlToPdf();
            var htmlPage = RenderRazorViewToString("~/Views/Bills/Bills.cshtml", billsViewModel);
            converter.Options.ExternalLinksEnabled = true;
            converter.Options.JavaScriptEnabled = true;
            converter.Options.EmbedFonts = true;
            converter.Options.PdfCompressionLevel = PdfCompressionLevel.NoCompression;
            converter.Options.PdfPageSize = PdfPageSize.A4;
            converter.Options.DrawBackground = true;
            PdfDocument doc = converter.ConvertHtmlString(htmlPage);
            var file = doc.Save();
            return new FileContentResult(file, "application/octet-stream");
        }

        [CustomAuthorize(Role.Distributor, Role.Customer)]
        public ActionResult BillsHistory()
        {
            return View();
        }

        [CustomAuthorize(Role.Distributor, Role.Customer)]
        public ActionResult BillsHistoryData(DateTime fromDate, DateTime toDate, int customerId = 0)
        {
            try
            {
                var billsViewModels = _orderService.BillsHistoryData(fromDate, toDate, customerId);
                return Json(new { Data = billsViewModels, Success = true }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { Data = new List<BillsViewModel>(), Success = false, Message = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [CustomAuthorize(Role.Distributor, Role.Customer)]
        public ActionResult BillsHistoryPDF(int id)
        {
            var billsViewModel = _orderService.GetBillsHistoryPDF(id);
            //var report = new ViewAsPdf("Bills", billsViewModel);
            //report.FileName = "Bill_" + DateTime.Now.ToString() + ".pdf";
            HtmlToPdf converter = new HtmlToPdf();
            var htmlPage = RenderRazorViewToString("~/Views/Bills/Bills.cshtml", billsViewModel);
            converter.Options.ExternalLinksEnabled = true;
            converter.Options.JavaScriptEnabled = true;
            converter.Options.EmbedFonts = true;
            converter.Options.PdfCompressionLevel = PdfCompressionLevel.NoCompression;
            converter.Options.PdfPageSize = PdfPageSize.A4;
            converter.Options.DrawBackground = true;
            PdfDocument doc = converter.ConvertHtmlString(htmlPage);
            var file = doc.Save();
            return new FileContentResult(file, "application/octet-stream");
            
        }

        [CustomAuthorize(Role.Distributor)]
        public ActionResult DeleteBill(int id)
        {
            try
            {
                _orderService.DeleteBills(id);
                return RedirectToAction(nameof(BillsHistory));
            }
            catch (Exception ex)
            {
                return RedirectToAction(nameof(BillsHistory));
            }
        }

        public string RenderRazorViewToString(string viewName, object model)
        {
            ViewData.Model = model;
            using (var sw = new StringWriter())
            {
                var viewResult = ViewEngines.Engines.FindPartialView(ControllerContext, viewName);
                var viewContext = new ViewContext(ControllerContext, viewResult.View, ViewData, TempData, sw);
                viewResult.View.Render(viewContext, sw);
                viewResult.ViewEngine.ReleaseView(ControllerContext, viewResult.View);
                return sw.GetStringBuilder().ToString();
            }
        }
    }
}