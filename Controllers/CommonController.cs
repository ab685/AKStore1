using AKStore.Extension;
using AKStore.Filters;
using AKStore.Models;
using AKStore.Services;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace AKStore.Controllers
{
    public class CommonController : Controller
    {
        private readonly IUserService _userService;
        public CommonController()
        {
            _userService = new UserService();
        }
        [CustomAuthorize(Role.SuperAdmin, Role.Admin, Role.Distributor, Role.Customer)]
        [HttpPost]
        public ActionResult SetDefualtPassword(string userName)
        {
            _userService.SetDefualtPassword(userName);
            return Redirect(Request.UrlReferrer.OriginalString);
        }

        [CustomAuthorize(Role.SuperAdmin, Role.Admin, Role.Distributor, Role.Customer)]
        public ActionResult UserDetails()
        {
            int userId = Convert.ToInt32(Session["LoggedInUserId"]);
            var usersModel = _userService.GetUsersById(userId);
            return View(usersModel);
        }

        [CustomAuthorize(Role.SuperAdmin, Role.Admin, Role.Distributor, Role.Customer)]
        [HttpGet]
        public ActionResult UpdatePassword()
        {

            return View();
        }
        [CustomAuthorize(Role.SuperAdmin, Role.Admin, Role.Distributor, Role.Customer)]
        [HttpPost]
        public ActionResult UpdatePassword(UpdatePassword updatePassword)
        {
            if (!ModelState.IsValid)
            {
                return View(nameof(UpdatePassword), updatePassword);
            }
            if (string.IsNullOrEmpty(updatePassword.NewPassword.Trim()) ||
                string.IsNullOrEmpty(updatePassword.OldPassword.Trim()) ||
                string.IsNullOrEmpty(updatePassword.ConfirmPassword.Trim())
                 )
            {
                ModelState.AddModelError("", "Please enter all fields");
                return View(nameof(UpdatePassword), updatePassword);
            }
            int userId = Convert.ToInt32(Session["LoggedInUserId"]);

            var isPasswordUpdated = _userService.UpdatePassword(updatePassword, userId);
            if (isPasswordUpdated == 1)
            {
                return RedirectToAction(nameof(UserDetails));
            }
            else
            {
                ModelState.AddModelError("", "Old password is not correct");
                return View(nameof(UpdatePassword), updatePassword);
            }


        }
        [CustomAuthorize(Role.SuperAdmin, Role.Admin, Role.Distributor, Role.Customer)]
        [HttpGet]
        public ActionResult UpdateProfile()
        {
            int userId = Convert.ToInt32(Session["LoggedInUserId"]);
            var usersModel = _userService.GetUsersById(userId);
            UpdateProfileModel updateProfileModel = new UpdateProfileModel()
            {
                FirstName = usersModel.FirstName,
                LastName = usersModel.LastName,
                Address = usersModel.Address,
                PostalCode = usersModel.PostalCode,
                PhNo1 = usersModel.PhNo1,
                PhNo2 = usersModel.PhNo2
            };
            return View(updateProfileModel);

        }
        [CustomAuthorize(Role.SuperAdmin, Role.Admin, Role.Distributor, Role.Customer)]
        [HttpPost]
        public ActionResult UpdateProfile(UpdateProfileModel updateProfileModel)
        {
            if (!ModelState.IsValid)
            {
                return View(nameof(UpdateProfile), updateProfileModel);
            }
            int userId = Convert.ToInt32(Session["LoggedInUserId"]);
            var isProfileUpdated = _userService.UpdateProfile(updateProfileModel, userId);
            if (isProfileUpdated == 1)
            {
                return RedirectToAction(nameof(UserDetails));
            }
            else
            {
                return View(nameof(UpdateProfile), updateProfileModel);
            }


        }
        public ActionResult DashBoard()
        {
            return View();
        }
        public ActionResult DashBoardData(DateTime fromDate, DateTime toDate, int orderStatusId, int customerId)
        {
           
            //cutomerId = Convert.ToInt32(Session["CustomerId"]);
            int distributorId = Convert.ToInt32(Session["DistributorId"]);
            var desData = _userService.GetDashBoardData(fromDate, toDate, orderStatusId, customerId, distributorId);
            var jsonstr = JsonConvert.SerializeObject(desData, Formatting.Indented);
            return Json(new { data = jsonstr, Success = true }, JsonRequestBehavior.AllowGet);
        }

    }
}