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
    [CustomAuthorize(Role.SuperAdmin)]
    public class AdminController : Controller
    {
        private readonly IAdminService _adminService;
        private readonly IUserService _userService;

        public AdminController()
        {
            _adminService = new AdminService();
            _userService = new UserService();
        }
        // GET: Admin
        public ActionResult Admins()
        {


            var admins = _adminService.GetAdmins();
            return View(admins);
        }
        [HttpGet]
        public ActionResult UpsertAdmin(int? id)
        {
            var admin= new AdminModel();
            if (id != null && id > 0)
            {
                admin = _adminService.GetAdminsById(Convert.ToInt32(id));
                return View(admin);
            }
            return View(admin);
        }
        [HttpPost]
        public ActionResult UpsertAdmin(AdminModel adminModel)
        {
            if (!ModelState.IsValid)
            {
                return View(adminModel);
            }

            if (adminModel.Id == 0)
            {
                if (_userService.IsUserNameExists(adminModel.UserName, 0))
                {
                    ModelState.AddModelError("UserName", "Username already exists");
                    return View(adminModel);
                }

            }
            _adminService.UpsertAdmin(adminModel);
            return RedirectToAction(nameof(Admins));
        }

        [HttpPost]
        public ActionResult DeleteAdmin(int id, bool isActive)
        {
            if (id <= 0)
                return RedirectToAction(nameof(Admins));

            _adminService.DeleteAdmin(id, isActive);
            return RedirectToAction(nameof(Admins));
        }
    }
}