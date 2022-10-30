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

    }
}