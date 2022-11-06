using AKStore.Entity;
using AKStore.Extension;
using AKStore.Models;
using Dapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace AKStore.Repository
{
    public class StocksRepository : BaseRepository<Stocks>, IStocksRepository
    {
        public List<StocksModel> GetStocks()
        {
            var p = new DynamicParameters();
           
            var Stockss = CommonOperations.Query<StocksModel>("dbo.GetStocks", p, commandType: System.Data.CommandType.StoredProcedure).ToList();
            return Stockss;
        }
      
    }
}

