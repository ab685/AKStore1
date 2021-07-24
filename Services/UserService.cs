using AKStore.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using AutoMapper;
using AKStore.Repository;
using AKStore.Entity;
using System.Data;

namespace AKStore.Services
{
    public class UserService : BaseService, IUserService
    {
        private readonly IUserRepository _userRepository;

        public UserService()
        {
            _userRepository = new UserRepository();
        }
        public IEnumerable<UsersModel> GetUsers()
        {
            List<Users> users = _userRepository.GetAll().ToList();
            return AutoMapper.Mapper.Map<IEnumerable<UsersModel>>(users);
        }
        public void UpsertUser(UsersModel usersModel)
        {
            var users = AutoMapper.Mapper.Map<Users>(usersModel);
            _userRepository.UpsertUser(users);
        }

        public IEnumerable<RolesModel> GetRoles()
        {
            var roles = _userRepository.GetRoles();
            return AutoMapper.Mapper.Map<IEnumerable<RolesModel>>(roles);
        }
        public UsersModel GetUsersById(int? userId)
        {
            var users = _userRepository.GetById(Convert.ToInt32(userId));
            return AutoMapper.Mapper.Map<UsersModel>(users);
        }
        public void DeleteUser(int id)
        {
            _userRepository.Delete(id);
        }
        public UsersModel GetPredecessorOfUser(Users users)
        {
            var user = _userRepository.GetPredecessorOfUser(users);
            return AutoMapper.Mapper.Map<UsersModel>(user);
        }

        public bool IsUserNameExists(string userName, int id = 0)
        {
            return _userRepository.IsUserNameExists(userName, id);
        }
        public bool SetDefualtPassword(string userName)
        {
            return _userRepository.SetDefualtPassword(userName);
        }

        public int UpdatePassword(UpdatePassword updatePassword, int userId)
        {
            return _userRepository.UpdatePassword(updatePassword, userId);
        }

        public int UpdateProfile(UpdateProfileModel updateProfileModel, int userId)
        {
            return _userRepository.UpdateProfile(updateProfileModel, userId);
        }
        public DataSet GetDashBoardData(DateTime? fromDate, DateTime? toDate, int orderStatusId = 3, int customerId = 0, int distributorId = 0)
        {
            return _userRepository.GetDashBoardData((fromDate ?? DateTime.Now.AddDays(-30)), (toDate ?? DateTime.Now), orderStatusId, customerId, distributorId);
        }
    }
}