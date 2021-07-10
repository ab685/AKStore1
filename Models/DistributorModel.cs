using System;
using System.ComponentModel.DataAnnotations;

namespace AKStore.Models
{
    public class DistributorModel : UsersDetailsModel
    {
        public int Id { get; set; }
        public int AdminId { get; set; }
       
    }
}