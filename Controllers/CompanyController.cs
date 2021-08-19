using AKStore.Extension;
using AKStore.Filters;
using AKStore.Models;
using AKStore.Services;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace AKStore.Controllers
{

    public class CompanyController : Controller
    {
        private readonly ICompanyService _companyService;
        private readonly ICategoryService _categoryService;
        private readonly IDistributorService distributorService;
        public CompanyController()
        {
            _companyService = new CompanyService();
            _categoryService = new CategoryService();
            distributorService = new DistributorService();
        }
        [CustomAuthorize(Role.Distributor, Role.Admin)]
        public ActionResult Company()
        {
            //var DistributorId = Convert.ToInt32(Session["DistributorId"]);
            var DistributorId = distributorService.FirstDistributor().Id;
            var CompanyModels = _companyService.GetCompanyByDistributorId(DistributorId);
            return View(CompanyModels);
        }
        [CustomAuthorize(Role.Admin)]
        [HttpGet]
        public ActionResult UpsertCompany(int? id)
        {
            // var DistributorId = Convert.ToInt32(Session["DistributorId"]);
            var DistributorId = distributorService.FirstDistributor().Id;
            var categories = _categoryService.GetCategoryByDistributorId(DistributorId);
            if (id != null && id > 0)
            {

                var companyModels = _companyService.GetCompanyById(Convert.ToInt32(id));

                companyModels.Category = new SelectList(categories, "Id", "Name", companyModels.CategoryId);
                return View(companyModels);
            }
            else
            {

                CompanyModel companyModels = new CompanyModel();
                companyModels.Category = new SelectList(categories, "Id", "Name");
                return View(companyModels);
            }
        }

        [HttpPost]
        [CustomAuthorize(Role.Admin)]
        public ActionResult UpsertCompany(CompanyModel companyModel)
        {
            try
            {
                //  var DistributorId = Convert.ToInt32(Session["DistributorId"]);
                var DistributorId = distributorService.FirstDistributor().Id;
                var categories = _categoryService.GetCategoryByDistributorId(DistributorId);
                companyModel.Category = new SelectList(categories, "Id", "Name", companyModel.CategoryId);
                if (companyModel == null)
                {
                    throw new ArgumentNullException(nameof(companyModel));
                }
                if (!ModelState.IsValid)
                {
                    return View(companyModel);
                }
                string filename = string.Empty;
                string pathToSave = Server.MapPath("~/Documents/images/company");
                HttpPostedFileBase file = companyModel.file;
                if (file != null)
                {

                    if (file.ContentLength != 0)
                    {
                        filename = Path.GetFileName(file.FileName);
                        filename = filename.Replace("'","").Replace(" ","_");
                        string fileExtension = Path.GetExtension(filename);
                        var allowed = new string[] { ".png", ".jpg", ".jpeg", ".gif" };
                        if (!allowed.Contains(fileExtension))
                        {
                            ModelState.AddModelError("file", "Only image files are allowed");
                            return View(companyModel);
                        }
                        ExtensionMethods.ResizeImage(Image.FromStream(file.InputStream), 240, 240, Path.Combine(pathToSave, filename));
                        // file.SaveAs(Path.Combine(pathToSave, filename));
                    }
                }
                companyModel.FilePath = filename;
                var tuple = _companyService.UpsertCompany(companyModel);
                if (tuple.Item1 == true)
                {
                    return RedirectToAction(nameof(Company));
                }
                else
                {
                    return View(companyModel);
                }
            }
            catch (Exception ex)
            {
                return Json(new { Success = false, Message = ex.Message });
            }
        }

        [CustomAuthorize(Role.Admin)]
        [HttpPost]
        public ActionResult DeleteCompany(int id)
        {
            try
            {
                if (id <= 0)
                    return RedirectToAction(nameof(Company));

                var tuple = _companyService.DeleteCompany(id);
                return RedirectToAction(nameof(Company));

            }
            catch (Exception ex)
            {
                return Json(new { Success = false, Message = ex.Message });
            }
        }
    }
}