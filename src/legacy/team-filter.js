document.addEventListener('DOMContentLoaded', () => {

    const parentButtons = document.querySelectorAll('[data-parent]');
    const childGroups = document.querySelectorAll('[data-filter-parent]');
    const cards = document.querySelectorAll('.js-master-card');

    let activeParent = parentButtons[0]?.dataset.parent;
    let activeChild = 'all';

    function applyFilter() {

        cards.forEach(card => {

            const matchParent =
                card.dataset.parent === activeParent;

            const matchChild =
                activeChild === 'all' ||
                card.dataset.child === activeChild;

            card.style.display =
                matchParent && matchChild
                    ? 'block'
                    : 'none';

        });

        window.dispatchEvent(new CustomEvent('filter'));

    }

    function showChildGroup(parentId) {

        childGroups.forEach(group => {

            const isActive = group.dataset.filterParent === parentId;

            group.classList.toggle('hidden', !isActive);

            if (isActive) {

                group.querySelectorAll('[data-child], [data-parent]')
                    .forEach(btn => btn.classList.remove('active'));

                const allButton = group.querySelector('[data-child="all"]');

                if (allButton) {
                    allButton.classList.add('active');
                }

            }

        });

    }

    parentButtons.forEach(btn => {

        btn.addEventListener('click', () => {

            activeParent = btn.dataset.parent;
            activeChild = 'all';

            parentButtons.forEach(button => {
                button.classList.remove('active');
            });

            btn.classList.add('active');

            showChildGroup(activeParent);

            applyFilter();

        });

    });

    childGroups.forEach(group => {

        group.addEventListener('click', e => {

            const button = e.target.closest('[data-child], [data-parent]');

            if (!button) {
                return;
            }

            group.querySelectorAll('[data-child], [data-parent]')
                .forEach(btn => btn.classList.remove('active'));

            button.classList.add('active');

            activeChild =
                button.dataset.child === 'all'
                    ? 'all'
                    : button.dataset.child;

            applyFilter();

        });

    });

    showChildGroup(activeParent);

    applyFilter();

});