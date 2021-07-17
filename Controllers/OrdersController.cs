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
        private readonly IProductService _productService;
        public OrdersController()
        {
            _orderService = new OrderService();
            _productService = new ProductService();
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
                return Json(new { data = new List<DistributorOrderDataModel>(), Success = false, Message = ex.Message.ToString() }, JsonRequestBehavior.AllowGet);

            }
        }

        [HttpPost]
        public ActionResult ChangeOrderStatus(List<int> selectedIds, int orderStatusId, DistributorOrderModel distributorOrderModel)
        {
            try
            {
                if (selectedIds.Count() <= 0)
                    return new HttpNotFoundResult("Not found record");


                var tuple = _orderService.UpdateOrderStatusById(selectedIds, orderStatusId);
                var DistributorId = Convert.ToInt32(Session["DistributorId"]);
                distributorOrderModel.DistributorId = DistributorId;
                var distributorOrders = _orderService.GetOrderDataForDistributor(distributorOrderModel);
                var message = tuple.Item2;

                return Json(new { data = distributorOrders, Success = true, Message = message }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { data = new List<DistributorOrderDataModel>(), Success = false, Message = ex.Message.ToString() }, JsonRequestBehavior.AllowGet);

            }

        }

        [HttpPost]
        public ActionResult DeleteOrder(List<int> selectedIds, int orderStatusId, DistributorOrderModel distributorOrderModel)
        {
            try
            {
                if (selectedIds.Count() <= 0)
                    return new HttpNotFoundResult("Not found record");


                var tuple = _orderService.UpdateOrderStatusById(selectedIds, orderStatusId);
                TempData["Messeage"] = tuple.Item2;
                var DistributorId = Convert.ToInt32(Session["DistributorId"]);
                distributorOrderModel.DistributorId = DistributorId;
                var distributorOrders = _orderService.GetOrderDataForDistributor(distributorOrderModel);
                var message = string.Empty;
                if (orderStatusId == 1)
                {
                    message = "Selected orders are changed to Ordered status";
                }
                else if (orderStatusId == 2)
                {
                    message = "Selected orders are changed to Confirmed status";
                }
                else if (orderStatusId == 3)
                {
                    message = "Selected orders are changed to Delivered status";
                }
                else if (orderStatusId == 4)
                {
                    message = "Selected orders are changed to Canceled status";
                }
                return Json(new { data = distributorOrders, Success = true, Message = message }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { data = new List<DistributorOrderDataModel>(), Success = false, Message = ex.Message.ToString() }, JsonRequestBehavior.AllowGet);

            }

        }

        [HttpGet]
        public ActionResult EditDistributorOrders(int id)
        {
            try
            {
                var DistributorId = Convert.ToInt32(Session["DistributorId"]);
                var products = _productService.GetProduct(DistributorId);
                var distributorOrders = _orderService.GetOrderDataForDistributorById(id);
                distributorOrders.Products = new SelectList(products, "Id", "Name", distributorOrders.ProductId);
                return View(distributorOrders);
            }
            catch (Exception ex)
            {
                return Json(new { data = new List<DistributorOrderDataModel>(), Success = false, Message = ex.Message.ToString() }, JsonRequestBehavior.AllowGet);

            }
        }
        [HttpPost]
        public ActionResult EditDistributorOrders(DistributorOrderDataModel distributorOrderDataModel)
        {
            try
            {
                var DistributorId = Convert.ToInt32(Session["DistributorId"]);
                var products = _productService.GetProduct(DistributorId);
                distributorOrderDataModel.Products = new SelectList(products, "Id", "Name", distributorOrderDataModel.ProductId);
                if (!ModelState.IsValid)
                {
                    return View(distributorOrderDataModel);
                }

                var distributorOrders = _orderService.UpsertOrderDistributor(distributorOrderDataModel);
                return RedirectToAction(nameof(DistributorOrders));
            }
            catch (Exception ex)
            {
                return Json(new { data = new List<DistributorOrderDataModel>(), Success = false, Message = ex.Message.ToString() }, JsonRequestBehavior.AllowGet);

            }
        }

    }
}