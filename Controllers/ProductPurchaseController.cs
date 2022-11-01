using AKStore.Models;
using AKStore.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace AKStore.Controllers
{
    public class ProductPurchaseController : Controller
    {
        private readonly IProductPurchaseService _ProductPurchaseService;

        private readonly IDistributorService distributorService;
        public ProductPurchaseController()
        {

            _ProductPurchaseService = new ProductPurchaseService();

            distributorService = new DistributorService();
        }

        public ActionResult ProductPurchase(int? Id)
        {
            var productPurchases = _ProductPurchaseService.GetProductPurchase(Id);
            return View(productPurchases);
        }

       
        [HttpPost]
        public ActionResult ChangeProductPurchaseData(int productPurchaseId, int productId, int quantity, decimal price)
        {
            try
            {
                _ProductPurchaseService.ChangeProductPurchaseData(productPurchaseId, productId, quantity, price);
                return RedirectToAction(nameof(ProductPurchase));
            }
            catch (Exception ex)
            {
                return Json(new { Data = new ProductPurchaseModel(), Success = false, Message = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

    }
}