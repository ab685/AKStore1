using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using AKStore.Entity;
using AKStore.Models;

namespace AKStore.Repository
{
    public interface IUserRepository: IBaseRepository<Users>
    {
        int UpsertUser(Users users);
        IEnumerable<Roles> GetRoles();
        Users GetPredecessorOfUser(Users users);
        bool IsUserNameExists(string userName, int id = 0);
        bool SetDefualtPassword(string userName);
        int UpdatePassword(UpdatePassword updatePassword,int userId);
        int UpdateProfile(UpdateProfileModel updateProfileModel, int userId);
    }
}
