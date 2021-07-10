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
    
    [CustomAuthorize(Role.Admin)]
    public class DistributorController : Controller
    {

        private readonly IDistributorService _distributorService;
        private readonly IUserService _userService;
        public DistributorController()
        {
            _distributorService = new DistributorService();
            _userService = new UserService();
        }
        // GET: Distributor
        public ActionResult Distributors()
        {
            var distributors = _distributorService.GetDistributors();
            return View(distributors);
        }
        [HttpGet]
        public ActionResult UpsertDistributor(int? id)
        {
            var distributor = new DistributorModel();
            if (id != null && id > 0)
            {
                 distributor = _distributorService.GetDistributorById(Convert.ToInt32(id));
                return View(distributor);
            }
            return View(distributor);
        }
        [HttpPost]
        public ActionResult UpsertDistributor(DistributorModel distributorModel)
        {
            if (!ModelState.IsValid)
            {
               return View(distributorModel);
            }
            if (distributorModel.Id == 0)
            {
                if(_userService.IsUserNameExists(distributorModel.UserName, 0))
                {
                    ModelState.AddModelError("UserName", "Username already exists");
                    return View(distributorModel);
                }
               
            }
            _distributorService.UpsertDistributor(distributorModel);
            return RedirectToAction(nameof(Distributors));
        }

        [HttpPost]
        public ActionResult DeleteDistributor(int id, bool isActive)
        {
            if (id <= 0)
                return RedirectToAction(nameof(Distributors));

            _distributorService.DeleteDistributor(id,isActive);
            return RedirectToAction(nameof(Distributors));
        }
    }
}