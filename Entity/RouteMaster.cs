using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace AKStore.Entity
{
    public class RouteMaster
    {
        public int Id { get; set; }
        public int DistributorId { get; set; }
        public string RouteName { get; set; }
        public string AreaName { get; set; }
        public string SocietyName { get; set; }
        public DateTime? InsertedDate { get; set; }
        public DateTime? UpdatedDate { get; set; }
        public int? UpdatedByUserId { get; set; }
        public int? InsertedByUserId { get; set; }

    } 
}
