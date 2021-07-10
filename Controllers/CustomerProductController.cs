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
    [CustomAuthorize(Role.Customer)]
    public class CustomerProductController : Controller
    {
        private readonly ICustomerService customerService;
        private readonly IOrderService orderService;

        public CustomerProductController()
        {
            customerService = new CustomerService();
            orderService = new OrderService();
        }
        [HttpGet]
        public ActionResult CustomerProduct(string search, int? page)
        {
            var customerId = Convert.ToInt32(Session["CustomerId"]);
            var products = customerService.GetProductDataByCustomerId(customerId, search, page);
            ViewBag.Messeage = TempData["Messeage"];
            ViewBag.IsError = TempData["IsError"];
            return View(products);
        }
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult AddOrder(CustomerProductModel ordersModel)
        {
            var url = Request.UrlReferrer.AbsoluteUri.ToString();
            if (ordersModel.Quantity == null || ordersModel.Quantity <= 0)
            {
                ModelState.AddModelError("Quantity", "Please enter valid quantity");
                TempData["Messeage"] = "Please enter valid quantity";
                TempData["IsError"] = true;
                return Redirect(url);
            }
            else if (!ModelState.IsValid)
            {
                TempData["IsError"] = true;
                return Redirect(url);
            }
            else
            {
                ordersModel.CustomerId = Convert.ToInt32(Session["CustomerId"]);
                ordersModel.OrderDate = DateTime.Now;
                var tuple = orderService.UpsertOrder(ordersModel);
                TempData["Messeage"] = tuple.Item2;
                TempData["IsError"] = false;
                return Redirect(url);
            }

        }

        public ActionResult OrderedProducts()
        {
            var customerId = Convert.ToInt32(Session["CustomerId"]);
            var products = customerService.GetOrdersByCustomerId(customerId);
            ViewBag.Messeage = TempData["Messeage"];
            return View(products);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult CancelOrderByCustmer(int id)
        {
            if (id <= 0)
                return new HttpNotFoundResult("Not found record");

            var orderStatusId =Convert.ToInt32(OrderStatus.Canceled);
            var tuple = orderService.UpdateOrderStatusById(id, orderStatusId);
            TempData["Messeage"] =tuple.Item2;
            return RedirectToAction(nameof(OrderedProducts));
        }
    }
}