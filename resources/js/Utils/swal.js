import Swal from 'sweetalert2';

export const SwalConfirm = ({
    title = 'Are you sure?',
    text = 'This action cannot be undone.',
    icon = 'warning',
    confirmButtonText = 'Yes, proceed',
    cancelButtonText = 'Cancel',
    confirmButtonColor = '#ea580c',
}) => {
    return Swal.fire({
        title,
        text,
        icon,
        showCancelButton: true,
        confirmButtonColor,
        cancelButtonColor: '#64748b',
        confirmButtonText,
        cancelButtonText,
        reverseButtons: true,
        customClass: {
            popup: 'rounded-2xl shadow-2xl border border-gray-100 p-6',
            title: 'text-xl font-bold text-gray-900',
            htmlContainer: 'text-sm text-gray-600',
            confirmButton: 'px-5 py-2.5 rounded-xl font-bold text-sm shadow-md',
            cancelButton: 'px-5 py-2.5 rounded-xl font-semibold text-sm',
        }
    });
};

export const SwalAlert = ({
    title = 'Notice',
    text = '',
    icon = 'info',
    confirmButtonText = 'OK',
    confirmButtonColor = '#ea580c'
}) => {
    return Swal.fire({
        title,
        text,
        icon,
        confirmButtonColor,
        confirmButtonText,
        customClass: {
            popup: 'rounded-2xl shadow-2xl border border-gray-100 p-6',
            title: 'text-xl font-bold text-gray-900',
            htmlContainer: 'text-sm text-gray-600',
            confirmButton: 'px-5 py-2.5 rounded-xl font-bold text-sm shadow-md',
        }
    });
};

export const SwalToast = (title, icon = 'success') => {
    const Toast = Swal.mixin({
        toast: true,
        position: 'top-end',
        showConfirmButton: false,
        timer: 3000,
        timerProgressBar: true,
        didOpen: (toast) => {
            toast.onmouseenter = Swal.stopTimer;
            toast.onmouseleave = Swal.resumeTimer;
        }
    });

    Toast.fire({
        icon,
        title
    });
};

export default Swal;
