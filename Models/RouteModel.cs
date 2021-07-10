using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace AKStore.Models
{
    public class RouteModel
    {
        public int Id { get; set; }
        [Required]
        public string RouteName { get; set; }
        [Required]
        public string AreaName { get; set; }
        [Required]
        public string SocietyName { get; set; }
        public DateTime? InsertedDate { get; set; }
        public DateTime? UpdatedDate { get; set; }

    } 
}
