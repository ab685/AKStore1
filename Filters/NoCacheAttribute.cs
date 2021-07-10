using System;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;

namespace AKStore.Filters
{
    public class NoCacheAttribute : ActionFilterAttribute
    {
        public override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            
            filterContext.HttpContext.Response.Cache.SetCacheability(HttpCacheability.NoCache);
            filterContext.HttpContext.Response.Cache.SetExpires(DateTime.UtcNow.AddMilliseconds(-1));
            filterContext.HttpContext.Response.Cache.SetNoStore();
            filterContext.HttpContext.Response.Cookies.Clear();
            filterContext.Result = new RedirectToRouteResult(
                new RouteValueDictionary
                {
                     { "controller", "Login" },
                     { "action", "Index" }
                });
            base.OnActionExecuting(filterContext);

        }
    }
}