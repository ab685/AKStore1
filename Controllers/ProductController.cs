using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;
using AKStore.Entity;
using AKStore.Extension;
using AKStore.Filters;
using AKStore.Models;
using AKStore.Services;


namespace AKStore.Controllers
{

    public class ProductController : Controller
    {

        private readonly IProductService productService;
        private readonly ICompanyService companyService;
        private readonly IDistributorService distributorService;
        public ProductController()
        {

            productService = new ProductService();
            companyService = new CompanyService();
            distributorService = new DistributorService();
        }
        [CustomAuthorize(Role.Distributor, Role.Admin)]
        public ActionResult Products()
        {
            try
            {
                //var DistributorId = Convert.ToInt32(Session["DistributorId"]);
                var DistributorId = distributorService.FirstDistributor().Id;
                var products = productService.GetProduct(DistributorId);
                return View(products);
            }
            catch (Exception ex)
            {
                return Json(new { Data = new List<CustomerModel>(), Success = false, Message = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        public ActionResult GetProductData()
        {
            try
            {
                var DistributorId = distributorService.FirstDistributor().Id;
                return Json(new { Data = productService.GetProduct(DistributorId).ToList(), Success = true, Message = "Product fetched successfully." }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { Data = new List<ProductMaster>(), Success = false, Message = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [CustomAuthorize(Role.Admin)]
        [HttpGet]
        public ActionResult UpsertProduct(int? id)
        {

            var DistributorId = distributorService.FirstDistributor().Id;
            var companies = companyService.GetCompanyByDistributorId(DistributorId);

            if (id != null && id > 0)
            {
                var products = productService.GetProductById(Convert.ToInt32(id));
                products.Company = new SelectList(companies, "Id", "Name", products.CompanyId);

                return View(products);
            }
            else
            {

                ProductModel productModel = new ProductModel();
                productModel.Company = new SelectList(companies, "Id", "Name");
                return View(productModel);
            }
        }

        [CustomAuthorize(Role.Admin)]
        [HttpPost]
        public ActionResult UpsertProduct(ProductModel productModel)
        {
            try
            {
                var DistributorId = distributorService.FirstDistributor().Id;
                var companies = companyService.GetCompanyByDistributorId(DistributorId);
                productModel.Company = new SelectList(companies, "Id", "Name", productModel.CompanyId);

                if (productModel == null)
                {
                    throw new ArgumentNullException(nameof(productModel));
                }
                if (!ModelState.IsValid)
                {
                    return View(productModel);
                }
                string filename = string.Empty;
                string pathToSave = Server.MapPath("~/Documents/images/product");
                HttpPostedFileBase file = productModel.file;
                if (file != null)
                {

                    if (file.ContentLength != 0)
                    {
                        filename = Path.GetFileName(file.FileName);

                        string fileExtension = Path.GetExtension(filename);
                        var allowed = new string[] { ".png", ".jpg", ".jpeg", ".gif" };
                        if (!allowed.Contains(fileExtension))
                        {
                            ModelState.AddModelError("file", "Only image files are allowed");
                            return View(productModel);
                        }
                        file.SaveAs(Path.Combine(pathToSave, filename));
                    }
                }
                productModel.FilePath = filename;
                var tuple = productService.UpsertProduct(productModel);
                if (tuple.Item1 == true)
                {
                    return RedirectToAction(nameof(Products));
                }
                else
                {
                    return View(productModel);
                }
            }
            catch (Exception ex)
            {
                return Json(new { Success = false, Message = ex.Message });
            }
        }

        [CustomAuthorize(Role.Admin)]
        [HttpPost]
        public ActionResult DeleteProduct(int id)
        {
            try
            {
                if (id <= 0)
                    return RedirectToAction(nameof(Products));

                var tuple = productService.DeleteProduct(id);
                return RedirectToAction(nameof(Products));

            }
            catch (Exception ex)
            {
                return Json(new { Success = false, Message = ex.Message });
            }
        }

        [HttpPost]
        public ActionResult ChangeProductData(int productId)
        {
            try
            {

                var product = productService.GetProductById(productId);
                return Json(new { Data = product, Success = true, Message = "Product Data fetched successfully" });
            }
            catch (Exception ex)
            {
                return Json(new { Data = new ProductModel(), Success = false, Message = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }


    }
}