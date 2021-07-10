using AKStore.Entity;
using AKStore.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace AKStore.Services
{
    public interface IRouteService
    {
        IEnumerable<RouteMaster> GetRoueData(int distributorId);
        Tuple<bool, string> UpsertRoute(RouteModel routeModel);
        void DeleteRoute(int routeId);
        IEnumerable<RouteModel> GetRouteModels(int retailerId);
    }
}
