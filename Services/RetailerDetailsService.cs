using AKStore.Entity;
using AKStore.Models;
using AKStore.Repository;
using System;
using System.Collections.Generic;
using System.Web;

namespace AKStore.Services
{
    public class RetailerDetailsService : BaseService, IRetailerDetailsService
    {
        private readonly IRetailerDetailsRepository _retailerDetailsRepository;
        private readonly IRetailerRepository _retailerRepository;
        private readonly IUserRepository _userRepository;
        private HttpContextBase Context { get; set; }
        public RetailerDetailsService()
        {
            _retailerRepository = new RetailerRepository();
            _retailerDetailsRepository = new RetailerDetailsRepository();
            _userRepository = new UserRepository();
        }
        public IEnumerable<RetailerDetailsModel> GetRetailerDetails()
        {
            var retailerDetails = _retailerDetailsRepository.GetRetailerDetails();
            return retailerDetails;
        }

        public RetailerDetailsModel GetRetailerDetailsById(int id)
        {
            var retailerDetails = _retailerDetailsRepository.GetRetailerDetailsById(id);
            return retailerDetails;
        }
        public void UpsertRetailerDetails(RetailerDetailsModel retailerDetailsModel)
        {
            var selectedRetailer = _retailerRepository.GetById(retailerDetailsModel.RetailerId);
            if (retailerDetailsModel.Id == 0)
            {
                Users user = new Users()
                {
                    FirstName = selectedRetailer.Name,
                    UserName = retailerDetailsModel.UserName,
                    Password = retailerDetailsModel.Password,
                    RoleId = 4,
                    IsActive = true,
                    Address= retailerDetailsModel.Address,
                    PhNo1= retailerDetailsModel.PhNo1,
                    PhNo2= retailerDetailsModel.PhNo2,
                    InsertedDate = DateTime.Now,
                    LoggedInCount = 0
                };
                var userId = _userRepository.UpsertUser(user);
                if (userId > 0)
                {
                    RetailerDetails retailerDetails = new RetailerDetails()
                    {

                        InsertedDate = DateTime.Now,
                        UserId = userId,
                        InsertedByUserId = Convert.ToInt32(HttpContext.Current.Session["LoggedInUserId"]),
                        RetailerId = retailerDetailsModel.RetailerId,

                    };
                    _retailerDetailsRepository.Create(retailerDetails);
                }

            }
            else
            {
                var retailerDetails = _retailerDetailsRepository.GetById(retailerDetailsModel.Id);
                if (retailerDetails != null)
                {
                    var user = _userRepository.GetById(retailerDetails.UserId);
                    if (user != null)
                    {
                        user.FirstName = selectedRetailer.Name;
                        user.UserName = retailerDetailsModel.UserName;
                        user.Password = retailerDetailsModel.Password;
                        user.IsActive = true;
                        user.Address = retailerDetailsModel.Address;
                        user.PhNo2 = retailerDetailsModel.PhNo2;
                        user.PhNo1 = retailerDetailsModel.PhNo1;
                        user.UpdatedDate = DateTime.Now;
                        _userRepository.UpsertUser(user);
                    }

                    retailerDetails.RetailerId = retailerDetailsModel.RetailerId;
                    retailerDetails.UserId = user.Id;
                    retailerDetails.UpdatedDate = DateTime.Now;
                    retailerDetails.UpdatedByUserId = Convert.ToInt32(HttpContext.Current.Session["LoggedInUserId"]);
                    _retailerDetailsRepository.SaveChanges();
                }

            }

        }

        public int GetRetailerDetailsByRetailerId(int id)
        {
            return _retailerDetailsRepository.GetRetailerDetailsByRetailerId(id);
        }
        public void DeleteRetailerDetails(int id, bool isActive)
        {
            var retailerDetail = _retailerDetailsRepository.GetById(id);
            if (retailerDetail != null)
            {
                var user = _userRepository.GetById(retailerDetail.UserId);
                if (user != null)
                {
                    user.IsActive = isActive;
                    _userRepository.SaveChanges();
                }
            }
        }
    }
}
