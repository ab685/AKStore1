using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using AKStore.Models;
using AKStore.Services;
namespace AKStore.Controllers
{

    public class OrdersController : Controller
    {
        private readonly IOrderService _orderService;
        public OrdersController()
        {
            _orderService = new OrderService();
        }
        public ActionResult DistributorOrders()
        {
            return View();
        }

        [HttpGet]
        public ActionResult DistributorOrdersData(DistributorOrderModel distributorOrderModel)
        {
            try
            {


                var DistributorId = Convert.ToInt32(Session["DistributorId"]);
                distributorOrderModel.DistributorId = DistributorId;
                var distributorOrders = _orderService.GetOrderDataForDistributor(distributorOrderModel);
                return Json(new { data = distributorOrders, Success = true }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { data = new List<DistributorOrderDataModel>(), Success = false,Message=ex.Message.ToString() }, JsonRequestBehavior.AllowGet);

            }
        }
    }
}