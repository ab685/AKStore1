using AKStore.Entity;
using AKStore.Models;
using AKStore.Repository;
using System;
using System.Collections.Generic;
using System.Web;

namespace AKStore.Services
{
    public class AdminService : BaseService, IAdminService
    {
        private readonly IAdminRepository _adminRepository;
        private readonly IUserRepository _userRepository;
        private readonly IDistributorRepository _distributorRepository;
        
        public AdminService()
        {
            _adminRepository = new AdminRepository();
            _userRepository = new UserRepository();
            _distributorRepository = new DistributorRepository();
          
        }
        public IEnumerable<AdminModel> GetAdmins()
        {
            var admins = _adminRepository.GetAdmins();
            return admins;
        }
        public AdminModel GetAdminsById(int adminId)
        {
            var admin = _adminRepository.GetAdminById(adminId);
            return admin;
        }
        public void UpsertAdmin(AdminModel adminModel)
        {
            if (adminModel.Id == 0)
            {
                Users user = new Users()
                {
                    FirstName = adminModel.FirstName,
                    LastName = adminModel.LastName,
                    UserName = adminModel.UserName,
                    Password = adminModel.Password,
                    RoleId = 2,
                    IsActive = true,
                    InsertedDate = DateTime.Now,
                    LoggedInCount = 0,
                    PhNo1 = adminModel.PhNo1,
                    PhNo2 = adminModel.PhNo2,
                    Address = adminModel.Address,
                    PostalCode = adminModel.PostalCode
                };
                var userId = _userRepository.UpsertUser(user);
                if (userId > 0)
                {
                    Admin admin = new Admin()
                    {
                        InsertedDate = DateTime.Now,
                        InsertedByUserId = Convert.ToInt32(HttpContext.Current.Session["LoggedInUserId"]),
                        UserId = userId
                    };
                    _adminRepository.Create(admin);
                }

            }
            else
            {
                var admin = _adminRepository.GetById(adminModel.Id);
                if (admin != null)
                {
                    var user = _userRepository.GetById(admin.UserId);
                    if (user != null)
                    {
                        user.FirstName = adminModel.FirstName;
                        user.LastName = adminModel.LastName;
                        user.Password = adminModel.Password;
                        user.UserName = adminModel.UserName;
                        user.IsActive = true;
                        user.UpdatedDate = DateTime.Now;
                        user.Address = adminModel.Address;
                        user.PostalCode = adminModel.PostalCode;
                        user.PhNo1 = adminModel.PhNo1;
                        user.PhNo2 = adminModel.PhNo2;
                        _userRepository.UpsertUser(user);
                    }

                    
                    admin.UpdatedDate = DateTime.Now;
                    admin.UpdatedByUserId = Convert.ToInt32(HttpContext.Current.Session["LoggedInUserId"]);
                    _adminRepository.SaveChanges();
                }

            }


        }

        public void DeleteAdmin(int adminId, bool isActive)
        {
            var admin = _adminRepository.GetById(adminId);
            if (admin != null)
            {
                var user = _userRepository.GetById(admin.UserId);
                if (user != null)
                {
                    user.IsActive = isActive;
                    _userRepository.SaveChanges();

                }
                if (isActive == false)
                {
                    var distributors = _distributorRepository.GetAll(x => x.AdminId == admin.Id);
                    if (distributors != null)
                    {
                        foreach (var distributor in distributors)
                        {

                            var disUsers = _userRepository.GetById(distributor.UserId);
                            if (disUsers != null)
                            {
                                disUsers.IsActive = false;
                                _userRepository.SaveChanges();
                            }

                           
                        }
                    }
                }
                //_adminRepository.Delete(admin.Id);
            }
        }
    }
}
