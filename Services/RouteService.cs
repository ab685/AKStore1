using AutoMapper;
using AKStore.Entity;
using AKStore.Models;
using AKStore.Repository;
using System;
using System.Collections.Generic;
using System.Web;

namespace AKStore.Services
{
    public class RouteService : BaseService, IRouteService
    {

        public IEnumerable<RouteModel> GetRouteModels(int distributorId)
        {
            var routeMasters = GetRoueData(distributorId);
            return AutoMapper.Mapper.Map<IEnumerable<RouteModel>>(routeMasters);
        }

        public IEnumerable<RouteMaster> GetRoueData(int distributorId)
        {
            RouteRepository routeRepository = new RouteRepository();
            var routeMasters = routeRepository.GetRoueData(distributorId);
            return routeMasters;

            // return AutoMapper.Mapper.Map<IEnumerable<RouteModel>>(routeMasters);
        }
        public RouteModel GetRouteById(int id)
        {
            RouteRepository routeRepository = new RouteRepository();
            var routeMaster = routeRepository.GetRouteById(id);
            return AutoMapper.Mapper.Map<RouteModel>(routeMaster);
        }

        public Tuple<bool, string> UpsertRoute(RouteModel routeModel)
        {
            RouteRepository routeRepository = new RouteRepository();
            var DistributorId = Convert.ToInt32(HttpContext.Current.Session["DistributorId"]);
            RouteMaster routeMaster = new RouteMaster()
            {

                Id = routeModel.Id,
                AreaName = routeModel.AreaName,
                RouteName = routeModel.RouteName,
                SocietyName = routeModel.SocietyName,
                 DistributorId= DistributorId,
            };
            return routeRepository.UpsertRoute(routeMaster);
        }

        public void DeleteRoute(int routeId)
        {
            RouteRepository routeRepository = new RouteRepository();
            routeRepository.DeleteRoute(routeId);
        }
    }
}
