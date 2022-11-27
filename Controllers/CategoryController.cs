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

    public class CategoryController : Controller
    {
        private readonly ICategoryService _categoryService;
        private readonly IDistributorService distributorService;
        public CategoryController()
        {
            _categoryService = new CategoryService();
            distributorService = new DistributorService();
        }
        [CustomAuthorize(Role.Distributor, Role.Admin)]
        public ActionResult Category()
        {
            var DistributorId = distributorService.FirstDistributor().Id;
            // var DistributorId = Convert.ToInt32(Session["DistributorId"]);
            var categoryModels = _categoryService.GetCategoryByDistributorId(DistributorId);
            return View(categoryModels);
        }
        [CustomAuthorize(Role.Distributor, Role.Admin)]
        [HttpGet]
        public ActionResult UpsertCategory(int? id)
        {

            if (id != null && id > 0)
            {
                var categoryModels = _categoryService.GetCategoryById(Convert.ToInt32(id));
                return View(categoryModels);
            }
            else
            {

                CategoryModel categoryModel = new CategoryModel();
                return View(categoryModel);
            }
        }

        [CustomAuthorize(Role.Distributor, Role.Admin)]
        [HttpPost]
        public ActionResult UpsertCategory(CategoryModel categoryModel)
        {
            try
            {

                if (categoryModel == null)
                {
                    throw new ArgumentNullException(nameof(categoryModel));
                }
                if (!ModelState.IsValid)
                {
                    return View(categoryModel);
                }
                string filename = string.Empty;
                string pathToSave = Server.MapPath("~/Documents/images/category");
                HttpPostedFileBase file = categoryModel.file;
                if (file != null)
                {

                    if (file.ContentLength != 0)
                    {
                        filename = Path.GetFileName(file.FileName);
                        filename = filename.Replace("'", "").Replace(" ", "_");
                        string fileExtension = Path.GetExtension(filename);
                        var allowed = new string[] { ".png", ".jpg", ".jpeg", ".gif" };
                        if (!allowed.Contains(fileExtension))
                        {
                            ModelState.AddModelError("file", "Only image files are allowed");
                            return View(categoryModel);
                        }
                        //file.SaveAs(Path.Combine(pathToSave, filename));
                        ExtensionMethods.ResizeImage(Image.FromStream(file.InputStream), 500, 500, Path.Combine(pathToSave, filename));

                    }
                }
                categoryModel.FilePath = filename;
                var tuple = _categoryService.UpsertCategory(categoryModel);
                if (tuple.Item1 == true)
                {
                    return RedirectToAction(nameof(Category));
                }
                else
                {
                    return View(categoryModel);
                }
            }
            catch (Exception ex)
            {
                return Json(new { Success = false, Message = ex.Message });
            }
        }

        [CustomAuthorize(Role.Distributor, Role.Admin)]
        [HttpPost]
        public ActionResult DeleteCategory(int id)
        {
            try
            {
                if (id <= 0)
                    return RedirectToAction(nameof(Category));

                var tuple = _categoryService.DeleteCategory(id);
                return RedirectToAction(nameof(Category));

            }
            catch (Exception ex)
            {
                return Json(new { Success = false, Message = ex.Message });
            }
        }
    }
}