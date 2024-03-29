﻿using AKStore.Extension;
using AKStore.Filters;
using AKStore.Models;
using AKStore.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.UI;

namespace AKStore.Controllers
{
   
    public class CustomerProductController : Controller
    {
        private readonly ICustomerService customerService;
        private readonly IOrderService orderService;
        private readonly ICompanyService companyService;
        private readonly ICategoryService categoryService;
        private readonly IDistributorService distributorService;
        public CustomerProductController()
        {
            customerService = new CustomerService();
            orderService = new OrderService();
            companyService = new CompanyService();
            categoryService = new CategoryService();
            distributorService = new DistributorService();
        }
        [HttpGet]
        [CustomAuthorize(Role.Customer)]
        public ActionResult CustomerProduct(string search, string company, string category, int? page)
        {
            var customerId = Convert.ToInt32(Session["CustomerId"]);
            var products = customerService.GetProductDataByCustomerId(customerId, search, company, category, page);
            var distributor = distributorService.FirstDistributor();
            ViewBag.CompanyModels = companyService.GetCompanyByDistributorId(distributor.Id).OrderBy(x => x.Name).ToList();
            ViewBag.CategoryModels = categoryService.GetCategoryByDistributorId(distributor.Id).OrderBy(x => x.Name).ToList();
            ViewBag.search = search;
            ViewBag.company = company;
            ViewBag.category = category;
            ViewBag.Messeage = TempData["Messeage"];
            ViewBag.IsError = TempData["IsError"];
            return View(products);
        }
      

        [HttpPost]
        [CustomAuthorize(Role.Customer)]
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



        [CustomAuthorize(Role.Customer)]
        public ActionResult OrderedProducts()
        {
            var customerId = Convert.ToInt32(Session["CustomerId"]);
            ViewBag.Messeage = TempData["Messeage"];
            return View();
        }

        [CustomAuthorize(Role.Customer)]
        public ActionResult OrderedProductsData(DistributorOrderModel distributorOrderModel)
        {
            try
            {
                var customerId = Convert.ToInt32(Session["CustomerId"]);
                var products = customerService.GetOrdersByCustomerId(customerId, distributorOrderModel.FromDate, distributorOrderModel.ToDate, distributorOrderModel.OrderStatusId);
                return Json(new { data = products, Success = true }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new
                {
                    data = new List<OrderModels>(),
                    Success = false,
                    Message = ex.Message.ToString()
                }, JsonRequestBehavior.AllowGet);

            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [CustomAuthorize(Role.Customer)]
        public ActionResult CancelOrderByCustmer(int id)
        {
            if (id <= 0)
                return new HttpNotFoundResult("Not found record");

            var orderStatusId = Convert.ToInt32(OrderStatus.Canceled);
            List<int> ids = new List<int>()
            {
                id
            };

            var tuple = orderService.UpdateOrderStatusById(ids, orderStatusId);
            TempData["Messeage"] = tuple.Item2;
            return RedirectToAction(nameof(OrderedProducts));
        }



        [HttpGet]
        [CustomAuthorize(Role.Distributor)]
        public ActionResult AddCustomerOrder(string search, string company, string category, string customer, int? page)
        {
            var customerId = Convert.ToInt32(Session["CustomerId"]);
            var products = customerService.GetProductDataByCustomerId(customerId, search, company, category, page);
            var distributor = distributorService.FirstDistributor();
            ViewBag.CompanyModels = companyService.GetCompanyByDistributorId(distributor.Id).OrderBy(x => x.Name).ToList();
            ViewBag.CustomerModel = customerService.GetCustomerData(distributor.Id).OrderBy(x => x.SerialNo).ToList();
            ViewBag.CategoryModels = categoryService.GetCategoryByDistributorId(distributor.Id).OrderBy(x => x.Name).ToList();
            ViewBag.search = search;
            ViewBag.company = company;
            ViewBag.customer = customer;
            ViewBag.category = category;
            ViewBag.Messeage = TempData["Messeage"];
            ViewBag.IsError = TempData["IsError"];
            return View(products);
        }

        [HttpPost]
        [CustomAuthorize(Role.Distributor)]
        [ValidateAntiForgeryToken]
        public ActionResult AddOrderByDistributor(CustomerProductModel ordersModel)
        {
            var url = Request.UrlReferrer.AbsoluteUri.ToString();
            if (ordersModel.Quantity == null || ordersModel.Quantity <= 0)
            {
                ModelState.AddModelError("Quantity", "Please enter valid quantity");
                return Json(new { Success = false, Message = "Please enter valid quantity" }, JsonRequestBehavior.AllowGet);
            }
            else if (!ModelState.IsValid)
            {

                return Json(new { Success = false, Message = "Please enter valid quantity" }, JsonRequestBehavior.AllowGet);
            }
            else
            {

                ordersModel.OrderDate = DateTime.Now;
                var tuple = orderService.UpsertOrder(ordersModel);

                return Json(new { Success = true, Message = tuple.Item2 }, JsonRequestBehavior.AllowGet);
            }

        }
    }
}