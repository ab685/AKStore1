using AutoMapper;
using AKStore.Entity;
using AKStore.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace AKStore.Repository
{
    public interface IRouteRepository : IBaseRepository<RouteMaster>
    {
         List<RouteMaster> GetRoueData();
         Tuple<bool, string> UpsertRoute(RouteMaster routeMaster);
         void DeleteRoute(int routeId);
    }
}
