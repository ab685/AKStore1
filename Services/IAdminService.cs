using AKStore.Models;
using System.Collections.Generic;

namespace AKStore.Services
{
    public interface IAdminService
    {
        IEnumerable<AdminModel> GetAdmins();
        void UpsertAdmin(AdminModel adminModel);
        AdminModel GetAdminsById(int adminModel);
        void DeleteAdmin(int adminId,bool isActive);
    }
}
