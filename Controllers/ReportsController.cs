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
    public class ReportsController : Controller
    {
        private readonly IOrderService _orderService;
        public ReportsController()
        {
            _orderService = new OrderService();

        }

        public ActionResult PurchaseSellReport()
        {
            return View();
        }
        [HttpPost]
        public ActionResult GetPurchaseSellReportData(DateTime? fromDate, DateTime? toDate, int customerId = 0, int productId = 0)
        {
            try
            {
                List<PurchaseSellReportModel> PurchaseSellReport = _orderService.PurchaseSellReport(customerId, productId, fromDate,toDate);
                return Json(new { Data = PurchaseSellReport, Success = true, Message = "PurchaseSellReport fetched successfully." });
            }
            catch (Exception ex)
            {
                return Json(new { Data = new List<PurchaseSellReportModel>(), Success = false, Message = ex.Message });
            }
        }
        public ActionResult PrintProfitReport(DateTime? fromDate, DateTime? toDate, int customerId = 0, int productId = 0)
        {
         
            
            List<PurchaseSellReportModel> PurchaseSellReport = _orderService.PurchaseSellReport(customerId, productId, fromDate, toDate);

            HtmlToPdf converter = new HtmlToPdf();
            var htmlPage = RenderRazorViewToString("~/Views/Reports/PrintProfitReport.cshtml", PurchaseSellReport);
            htmlPage = htmlPage.Replace("/Documents/images/product/", Server.MapPath("~/Documents/images/product/")); htmlPage.Replace("/Documents/images/product/", Server.MapPath("~/Documents/images/product/"));
           
            converter.Options.ExternalLinksEnabled = true;
            converter.Options.JavaScriptEnabled = true;
            converter.Options.EmbedFonts = true;
            converter.Options.PdfCompressionLevel = PdfCompressionLevel.Normal;
            converter.Options.PdfPageSize = PdfPageSize.A4;
            converter.Options.DrawBackground = true;

            PdfDocument doc = converter.ConvertHtmlString(htmlPage);
            var file = doc.Save();
            return new FileContentResult(file, "application/octet-stream");
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