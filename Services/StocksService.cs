using AKStore.Models;
using AKStore.Repository;
using System.Collections.Generic;
namespace AKStore.Services
{
    public class StocksService : BaseService, IStocksService
    {
        private readonly IStocksRepository _StocksRepository;
        public StocksService() : base()
        {
            _StocksRepository = new StocksRepository();
        }

        public List<StocksModel> GetStocks()
        {
            return _StocksRepository.GetStocks();
        }
       

    }
}
