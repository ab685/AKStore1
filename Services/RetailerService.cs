using AKStore.Entity;
using AKStore.Models;
using AKStore.Repository;
using System;
using System.Collections.Generic;
using System.Web;
using System.Linq;

namespace AKStore.Services
{
    public class RetailerService : BaseService, IRetailerService
    {
        private readonly IRetailerRepository _retailerRepository;
        private readonly IRetailerDetailsRepository _retailerDetailsRepository;
        private readonly IUserRepository _userRepository;
        private HttpContextBase Context { get; set; }
        public RetailerService()
        {
            _retailerDetailsRepository = new RetailerDetailsRepository();
            _retailerRepository = new RetailerRepository();
            _userRepository = new UserRepository();
        }

        public IEnumerable<RetailerModel> GetRetailers()
        {
            var DistributorId = Convert.ToInt32(HttpContext.Current.Session["DistributorId"]);
            var retailers = _retailerRepository.GetAll(x => x.DistributorId == DistributorId);
            return AutoMapper.Mapper.Map<IEnumerable<RetailerModel>>(retailers);
        }
        public void UpsertRetailerDetails(RetailerDetailsModel retailerDetailsModel)
        {

            if (retailerDetailsModel.Id == 0)
            {
                Users user = new Users()
                {
                    FirstName = retailerDetailsModel.Name,
                    UserName = retailerDetailsModel.UserName,
                    Password = retailerDetailsModel.Password,
                    RoleId = 4,
                    IsActive = true,
                    Address = retailerDetailsModel.Address,
                    PhNo1 = retailerDetailsModel.PhNo1,
                    PhNo2 = retailerDetailsModel.PhNo2,
                    InsertedDate = DateTime.Now,
                    LoggedInCount = 0
                };
                var userId = _userRepository.UpsertUser(user);
                if (userId > 0)
                {
                    Retailer retailer = new Retailer()
                    {
                        Name = retailerDetailsModel.Name,
                        InsertedByUserId = Convert.ToInt32(HttpContext.Current.Session["LoggedInUserId"]),
                        InsertedDate = DateTime.Now,
                        DistributorId = Convert.ToInt32(HttpContext.Current.Session["DistributorId"]),
                    };
                    _retailerRepository.Create(retailer);
                    var insertedRetailer = _retailerRepository.GetAll();
                    var insertedRetailerId = insertedRetailer.AsEnumerable().LastOrDefault().Id;
                    RetailerDetails retailerDetails = new RetailerDetails()
                    {

                        InsertedDate = DateTime.Now,
                        UserId = userId,
                        InsertedByUserId = Convert.ToInt32(HttpContext.Current.Session["LoggedInUserId"]),
                        RetailerId = insertedRetailerId,

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
                        user.FirstName = retailerDetailsModel.Name;
                        user.UserName = retailerDetailsModel.UserName;
                        user.Password = retailerDetailsModel.Password;
                        user.IsActive = true;
                        user.Address = retailerDetailsModel.Address;
                        user.PhNo1 = retailerDetailsModel.PhNo1;
                        user.PhNo2 = retailerDetailsModel.PhNo2;
                        user.UpdatedDate = DateTime.Now;
                        _userRepository.UpsertUser(user);
                    }
                    var selectedRetailer = _retailerRepository.GetById(retailerDetailsModel.RetailerId);
                    if (selectedRetailer != null)
                    {
                        selectedRetailer.Name = retailerDetailsModel.Name;
                        selectedRetailer.UpdatedByUserId = Convert.ToInt32(HttpContext.Current.Session["LoggedInUserId"]);
                        selectedRetailer.UpdatedDate = DateTime.Now;
                        _retailerRepository.SaveChanges();
                    }
                    retailerDetails.RetailerId = retailerDetailsModel.RetailerId;
                    retailerDetails.UserId = user.Id;
                    retailerDetails.UpdatedDate = DateTime.Now;
                    retailerDetails.UpdatedByUserId = Convert.ToInt32(HttpContext.Current.Session["LoggedInUserId"]);
                    _retailerDetailsRepository.SaveChanges();
                }

            }

        }
    }
}
