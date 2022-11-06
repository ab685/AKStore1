using AKStore.Models;
using AKStore.Services;
using System;
using System.Web.Mvc;

namespace AKStore.Controllers
{
    public class StocksController : Controller
    {
        private readonly IStocksService _StocksService;

        private readonly IDistributorService distributorService;
        public StocksController()
        {

            _StocksService = new StocksService();

            distributorService = new DistributorService();
        }

        public ActionResult Stocks(int? Id)
        {
            var Stockss = _StocksService.GetStocks();
            return View(Stockss);
        }

    }
}