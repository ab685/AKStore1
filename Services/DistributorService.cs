using AKStore.Entity;
using AKStore.Models;
using AKStore.Repository;
using System;
using System.Collections.Generic;
using System.Web;

namespace AKStore.Services
{
    public class DistributorService : BaseService, IDistributorService
    {
        private readonly IDistributorRepository _distributorRepository;
        private readonly IUserRepository _userRepository;

        private HttpContextBase Context { get; set; }
        public DistributorService()
        {

            _distributorRepository = new DistributorRepository();
            _userRepository = new UserRepository();


        }
        public IEnumerable<DistributorModel> GetDistributors()
        {
            var distributors = _distributorRepository.GetDistributors();
            return distributors;
        }
        public DistributorModel GetDistributorById(int distributorId)
        {
            var distributor = _distributorRepository.GetDistributorById(distributorId);
            return distributor;
        }
        public void UpsertDistributor(DistributorModel distributorModel)
        {
            if (distributorModel.Id == 0)
            {
                Users user = new Users()
                {
                    FirstName = distributorModel.FirstName,
                    LastName = distributorModel.LastName,
                    UserName = distributorModel.UserName,
                    Password = distributorModel.Password,
                    RoleId = 3,
                    IsActive = true,
                    Address = distributorModel.Address,
                    PostalCode = distributorModel.PostalCode,
                    PhNo1 = distributorModel.PhNo1,
                    PhNo2 = distributorModel.PhNo2,
                    InsertedDate = DateTime.Now,
                    LoggedInCount = 0
                };
                var userId = _userRepository.UpsertUser(user);
                if (userId > 0)
                {
                    Distributor distributor = new Distributor()
                    {

                        InsertedDate = DateTime.Now,
                        InsertedByUserId = Convert.ToInt32(HttpContext.Current.Session["LoggedInUserId"]),
                        UserId = userId,
                        Name = distributorModel.Name,
                        AdminId = Convert.ToInt32(HttpContext.Current.Session["AdminId"])
                    };
                    _distributorRepository.Create(distributor);
                }

            }
            else
            {
                var distributor = _distributorRepository.GetById(distributorModel.Id);
                if (distributor != null)
                {
                    var user = _userRepository.GetById(distributor.UserId);
                    if (user != null)
                    {
                        user.FirstName = distributorModel.FirstName;
                        user.LastName = distributorModel.LastName;
                        user.Password = distributorModel.Password;
                        user.IsActive = true;
                        user.PostalCode = distributorModel.PostalCode;
                        user.Address = distributorModel.Address;
                        user.PhNo1 = distributorModel.PhNo1;
                        user.PhNo2 = distributorModel.PhNo2;
                        user.UpdatedDate = DateTime.Now;
                        _userRepository.UpsertUser(user);
                    }


                    distributor.UpdatedDate = DateTime.Now;
                    distributor.UpdatedByUserId = Convert.ToInt32(HttpContext.Current.Session["LoggedInUserId"]);
                    distributor.AdminId = Convert.ToInt32(HttpContext.Current.Session["AdminId"]);
                    distributor.Name = distributorModel.Name;
                    _distributorRepository.SaveChanges();
                }

            }


        }

        public void DeleteDistributor(int distributorId, bool isActive)
        {
            var distributor = _distributorRepository.GetById(distributorId);
            if (distributor != null)
            {
                var user = _userRepository.GetById(distributor.UserId);
                if (user != null)
                {
                    user.IsActive = isActive;
                    _userRepository.SaveChanges();
                }

                if (isActive == false)
                {

                }
                //_distributorRepository.Delete(distributor.Id);
            }
        }
        public Distributor FirstDistributor()
        {
            return _distributorRepository.FirstDistributor();
        }
    }
}
