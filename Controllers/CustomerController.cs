using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AKStore.Entity;
using AKStore.Extension;
using AKStore.Filters;

using AKStore.Services;
using AKStore.Models;
using System.Web.Mvc;

namespace AKStore.Controllers
{
   
    public class CustomerController : Controller
    {

        private readonly ICustomerService _customerService;
        private readonly IRouteService _routeService;
        private readonly IProductService _productService;
        private readonly IUserService _userService;
        private readonly IDistributorService distributorService;
        public CustomerController()
        {
            _productService = new ProductService();
            _customerService = new CustomerService();
            _routeService = new RouteService();
            _userService = new UserService();
            distributorService = new DistributorService();
        }

        [CustomAuthorize(Role.Distributor, Role.Admin)]
        public ActionResult Customers()
        {
            try
            {
                //var DistributorId = Convert.ToInt32(Session["DistributorId"]);
                var DistributorId = distributorService.FirstDistributor().Id;
                var customers = _customerService.GetCustomerData(DistributorId);
                return View(customers);
            }
            catch (Exception ex)
            {
                return Json(new { Data = new List<CustomerModel>(), Success = false, Message = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }
        [CustomAuthorize(Role.Distributor, Role.Admin)]
        [HttpGet]
        public ActionResult GetCustomerData()
        {
            try
            {
                //var DistributorId = Convert.ToInt32(Session["DistributorId"]);
                var DistributorId = distributorService.FirstDistributor().Id;
                return Json(new { Data = _customerService.GetCustomerData(DistributorId).ToList(), Success = true, Message = "Customer fetched successfully." }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { Data = new List<CustomerModel>(), Success = false, Message = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [CustomAuthorize(Role.Admin)]
        [HttpGet]
        public ActionResult UpsertCustomer(int? id)
        {
            //var DistributorId = Convert.ToInt32(Session["DistributorId"]);
            var DistributorId = distributorService.FirstDistributor().Id;
            if (id != null && id > 0)
            {
                var customer = _customerService.GetCustomerDataById(Convert.ToInt32(id));
                return View(customer);
            }
            else
            {
                CustomerModel customer = new CustomerModel();
                return View(customer);
            }


        }

        [HttpPost]
        [CustomAuthorize(Role.Admin)]
        [ValidateAntiForgeryToken]
        public ActionResult UpsertCustomer(CustomerModel customerModel)
        {
            try
            {
                //var DistributorId = Convert.ToInt32(Session["DistributorId"]);
                var DistributorId = distributorService.FirstDistributor().Id;

                if (!ModelState.IsValid)
                {
                    return View(customerModel);
                }
                if (customerModel.Id == 0)
                {
                    if (_userService.IsUserNameExists(customerModel.UserName, 0))
                    {
                        ModelState.AddModelError("UserName", "Username already exists");
                        return View(customerModel);
                    }

                }
                var tuple = _customerService.UpsertCustomer(customerModel);
                if (tuple.Item1 == true)
                {
                    return RedirectToAction(nameof(Customers));
                }
                else
                {
                    return View(customerModel);
                }
            }
            catch (Exception ex)
            {
                return Json(new { Success = false, Message = ex.Message });
            }
        }

        [HttpPost]
        [CustomAuthorize(Role.Admin)]
        public ActionResult DeleteCustomer(int id)
        {
            try
            {
                if (id <= 0)
                    return RedirectToAction(nameof(Customers));


                var tuple = _customerService.DeleteCustomer(id);
                return RedirectToAction(nameof(Customers));

            }
            catch (Exception ex)
            {
                return Json(new { Success = false, Message = ex.Message });
            }
        }
    }
}