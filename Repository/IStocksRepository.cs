using AKStore.Entity;
using AKStore.Models;
using System.Collections.Generic;

namespace AKStore.Repository
{
    public interface IStocksRepository : IBaseRepository<Stocks>
    {
        List<StocksModel> GetStocks();
        
    }
}
