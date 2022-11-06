using System.Collections.Generic;
using AKStore.Models;
namespace AKStore.Services
{
    public interface IStocksService
    {
        List<StocksModel> GetStocks();
       
    }
}
