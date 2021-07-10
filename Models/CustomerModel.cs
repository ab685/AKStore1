using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;
using System.Web.Mvc;

namespace AKStore.Models
{
    public class CustomerModel:UsersDetailsModel
    {
        public int Id { get; set; }
        [Required]
       
        public int SerialNo { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "Store Name is required")]
        [RegularExpression(@"^.*\S.*$", ErrorMessage = "Store Name is required")]
        public string StoreName { get; set; }

    }
}
