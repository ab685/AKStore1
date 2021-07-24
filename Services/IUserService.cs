using AKStore.Entity;
using AKStore.Models;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;

namespace AKStore.Services
{
    public interface IUserService
    {
        IEnumerable<UsersModel> GetUsers();
        void UpsertUser(UsersModel usersModel);
        IEnumerable<RolesModel> GetRoles();
        UsersModel GetUsersById(int? userId);
        void DeleteUser(int id);
        UsersModel GetPredecessorOfUser(Users users);
        bool IsUserNameExists(string userName, int id = 0);
        bool SetDefualtPassword(string userName);
        int UpdatePassword(UpdatePassword updatePassword, int userId);
        int UpdateProfile(UpdateProfileModel updateProfileModel, int userId);
        DataSet GetDashBoardData(DateTime? fromDate, DateTime? toDate, int orderStatusId = 3, int customerId = 0, int distributorId = 0);

    }
}