using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace AKStore.Models
{
    public class UsersModel:UsersDetailsModel
    {
        public int Id { get; set; }
        
        [Required]
        public int? RoleId { get; set; }
       
        

    }
}