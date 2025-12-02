<script lang="ts">
  import Thumbnail from '$lib/components/assets/thumbnail/thumbnail.svelte';
  import type { Something } from '$lib/components/timeline/Timeline.svelte';
  import { eventManager } from '$lib/managers/event-manager.svelte';
  import type { DayGroup } from '$lib/managers/timeline-manager/day-group.svelte';
  import type { MonthGroup } from '$lib/managers/timeline-manager/month-group.svelte';
  import { TimelineManager } from '$lib/managers/timeline-manager/timeline-manager.svelte';
  import type { TimelineAsset } from '$lib/managers/timeline-manager/types';
  import { assetSnapshot, assetsSnapshot } from '$lib/managers/timeline-manager/utils.svelte';
  import { viewTransitionManager } from '$lib/managers/ViewTransitionManager.svelte';
  import type { AssetInteraction } from '$lib/stores/asset-interaction.svelte';
  import { assetViewingStore } from '$lib/stores/asset-viewing.store';
  import { isSelectingAllAssets } from '$lib/stores/assets-store.svelte';
  import { uploadAssetsStore } from '$lib/stores/upload';
  import { navigate } from '$lib/utils/navigation';
  import { fromTimelinePlainDate, getDateLocaleString } from '$lib/utils/timeline-util';
  import { Icon } from '@immich/ui';
  import { mdiCheckCircle, mdiCircleOutline } from '@mdi/js';
  import { tick, type Snippet } from 'svelte';

  let { isUploading } = uploadAssetsStore;
  let { isViewing: showAssetViewer } = assetViewingStore;

  interface Props {
    shared: Something;
    isSelectionMode: boolean;
    singleSelect: boolean;
    withStacked: boolean;
    showArchiveIcon: boolean;
    monthGroup: MonthGroup;
    timelineManager: TimelineManager;
    assetInteraction: AssetInteraction;
    customLayout?: Snippet<[TimelineAsset]>;

    onSelect: ({ title, assets }: { title: string; assets: TimelineAsset[] }) => void;
    onSelectAssets: (asset: TimelineAsset) => void;
    onSelectAssetCandidates: (asset: TimelineAsset | null) => void;
    onThumbnailClick?: (
      asset: TimelineAsset,
      timelineManager: TimelineManager,
      dayGroup: DayGroup,
      onClick: (
        timelineManager: TimelineManager,
        assets: TimelineAsset[],
        groupTitle: string,
        asset: TimelineAsset,
      ) => void,
    ) => void;
  }

  let {
    shared,
    isSelectionMode,
    singleSelect,
    withStacked,
    showArchiveIcon,
    monthGroup = $bindable(),
    assetInteraction,
    timelineManager,
    customLayout,
    onSelect,
    onSelectAssets,
    onSelectAssetCandidates,

    onThumbnailClick,
  }: Props = $props();

  let isMouseOverGroup = $state(false);
  let hoveredDayGroup = $state();
  const send = shared.send;

  let animationTargetAssetId = $state<string | null>(null);

  const transitionDuration = $derived.by(() =>
    monthGroup.timelineManager.suspendTransitions && !$isUploading ? 0 : 150,
  );
  const scaleDuration = $derived(transitionDuration === 0 ? 0 : transitionDuration + 100);
  const _onClick = (
    timelineManager: TimelineManager,
    assets: TimelineAsset[],
    groupTitle: string,
    asset: TimelineAsset,
  ) => {
    if (isSelectionMode || assetInteraction.selectionActive) {
      assetSelectHandler(timelineManager, asset, assets, groupTitle);
      return;
    }
    void navigate({ targetRoute: 'current', assetId: asset.id });
  };

  const handleSelectGroup = (title: string, assets: TimelineAsset[]) => onSelect({ title, assets });

  const assetSelectHandler = (
    timelineManager: TimelineManager,
    asset: TimelineAsset,
    assetsInDayGroup: TimelineAsset[],
    groupTitle: string,
  ) => {
    onSelectAssets(asset);

    // Check if all assets are selected in a group to toggle the group selection's icon
    let selectedAssetsInGroupCount = assetsInDayGroup.filter((asset) =>
      assetInteraction.hasSelectedAsset(asset.id),
    ).length;

    // if all assets are selected in a group, add the group to selected group
    if (selectedAssetsInGroupCount == assetsInDayGroup.length) {
      assetInteraction.addGroupToMultiselectGroup(groupTitle);
    } else {
      assetInteraction.removeGroupFromMultiselectGroup(groupTitle);
    }

    if (timelineManager.assetCount == assetInteraction.selectedAssets.length) {
      isSelectingAllAssets.set(true);
    } else {
      isSelectingAllAssets.set(false);
    }
  };

  const assetMouseEventHandler = (groupTitle: string, asset: TimelineAsset | null) => {
    // Show multi select icon on hover on date group
    hoveredDayGroup = groupTitle;

    if (assetInteraction.selectionActive) {
      onSelectAssetCandidates(asset);
    }
  };

  function filterIntersecting<R extends { intersecting: boolean }>(intersectable: R[]) {
    return intersectable.filter((int) => int.intersecting);
  }

  const getDayGroupFullDate = (dayGroup: DayGroup): string => {
    const { month, year } = dayGroup.monthGroup.yearMonth;
    const date = fromTimelinePlainDate({
      year,
      month,
      day: dayGroup.day,
    });
    return getDateLocaleString(date);
  };
  let transitionTargetAssetId = $state<string | null>(null);

  eventManager.on('TransitionToTimeline', ({ id }) => {
    const asset = monthGroup.findAssetById({ id });
    if (!asset) {
      return;
    }

    viewTransitionManager.startTransition(
      new Promise<void>((resolve) => {
        console.log('BACK TO TIMLEINE');
        eventManager.once('TimelineLoaded', ({ id }) => {
          console.log('timeline loaded', id);
          transitionTargetAssetId = id;
          resolve();
        });
      }),
      () => {
        console.log('finished loaded', id);
        transitionTargetAssetId = null;
      },
    );
  });
</script>

{#each filterIntersecting(monthGroup.dayGroups) as dayGroup, groupIndex (dayGroup.day)}
  {@const absoluteWidth = dayGroup.left}

  <!-- svelte-ignore a11y_no_static_element_interactions -->
  <section
    class={[
      { 'transition-all': !monthGroup.timelineManager.suspendTransitions },
      !monthGroup.timelineManager.suspendTransitions && `delay-${transitionDuration}`,
    ]}
    data-group
    style:position="absolute"
    style:transform={`translate3d(${absoluteWidth}px,${dayGroup.top}px,0)`}
    onmouseenter={() => {
      isMouseOverGroup = true;
      assetMouseEventHandler(dayGroup.groupTitle, null);
    }}
    onmouseleave={() => {
      isMouseOverGroup = false;
      assetMouseEventHandler(dayGroup.groupTitle, null);
    }}
  >
    <!-- Date group title -->
    <div
      class="flex pt-7 pb-5 max-md:pt-5 max-md:pb-3 h-6 place-items-center text-xs font-medium text-immich-fg dark:text-immich-dark-fg md:text-sm"
      style:width={dayGroup.width + 'px'}
    >
      {#if !singleSelect}
        <div
          class="hover:cursor-pointer transition-all duration-200 ease-out overflow-hidden w-0"
          class:w-8={(hoveredDayGroup === dayGroup.groupTitle && isMouseOverGroup) ||
            assetInteraction.selectedGroup.has(dayGroup.groupTitle)}
          onclick={() => handleSelectGroup(dayGroup.groupTitle, assetsSnapshot(dayGroup.getAssets()))}
          onkeydown={() => handleSelectGroup(dayGroup.groupTitle, assetsSnapshot(dayGroup.getAssets()))}
        >
          {#if assetInteraction.selectedGroup.has(dayGroup.groupTitle)}
            <Icon icon={mdiCheckCircle} size="24" class="text-primary" />
          {:else}
            <Icon icon={mdiCircleOutline} size="24" color="#757575" />
          {/if}
        </div>
      {/if}

      <span class="w-full truncate first-letter:capitalize" title={getDayGroupFullDate(dayGroup)}>
        {dayGroup.groupTitle}
      </span>
    </div>

    <!-- Image grid -->
    <div
      data-image-grid
      class="relative overflow-clip"
      style:height={dayGroup.height + 'px'}
      style:width={dayGroup.width + 'px'}
    >
      {#each filterIntersecting(dayGroup.viewerAssets) as viewerAsset (viewerAsset.id)}
        {@const position = viewerAsset.position!}
        {@const asset = viewerAsset.asset!}
        {@const transitionName =
          animationTargetAssetId === asset.id || transitionTargetAssetId === asset.id ? 'good' : undefined}

        <!-- {#if viewerAsset.intersecting} -->
        <!-- note: don't remove data-asset-id - its used by web e2e tests -->
        <div
          data-asset-id={asset.id}
          data-transition-thumb={animationTargetAssetId === asset.id || transitionTargetAssetId === asset.id
            ? true
            : undefined}
          style:view-transition-name={transitionName}
          class="absolute"
          style:top={position.top + 'px'}
          style:left={position.left + 'px'}
          style:width={position.width + 'px'}
          style:height={position.height + 'px'}
        >
          <!--  out:send={{ key: asset.id }} -->
          <Thumbnail
            showStackedIcon={withStacked}
            {showArchiveIcon}
            {asset}
            {groupIndex}
            onClick={async (asset) => {
              console.log('adding clickedThumb', asset.id);

              // tag  target on the 'old' snaptho
              animationTargetAssetId = asset.id;
              viewTransitionManager.startTransition(
                new Promise<void>((resolve) =>
                  eventManager.once('AssetViewerLoaded', () => {
                    eventManager.emit('TransitionToAssetViewer');
                    tick().then(resolve, () => void 0);
                    // resolve();
                  }),
                ),
              );

              eventManager.once('StartViewTransition', () => {
                console.log('removing clickedThumb');
                // remove target on the 'old' view,
                // asset-viewer will tag new target element for 'new' snapshot
                animationTargetAssetId = null;
              });

              if (typeof onThumbnailClick === 'function') {
                onThumbnailClick(asset, timelineManager, dayGroup, _onClick);
              } else {
                _onClick(timelineManager, dayGroup.getAssets(), dayGroup.groupTitle, asset);
              }
            }}
            onSelect={(asset) => assetSelectHandler(timelineManager, asset, dayGroup.getAssets(), dayGroup.groupTitle)}
            onMouseEvent={() => assetMouseEventHandler(dayGroup.groupTitle, assetSnapshot(asset))}
            selected={assetInteraction.hasSelectedAsset(asset.id) ||
              dayGroup.monthGroup.timelineManager.albumAssets.has(asset.id)}
            selectionCandidate={assetInteraction.hasSelectionCandidate(asset.id)}
            disabled={dayGroup.monthGroup.timelineManager.albumAssets.has(asset.id)}
            thumbnailWidth={position.width}
            thumbnailHeight={position.height}
          />

          {#if customLayout}
            {@render customLayout(asset)}
          {/if}
        </div>
        <!-- {/if} -->
      {/each}
    </div>
  </section>
{/each}

<style>
  section {
    contain: layout paint style;
  }
  [data-image-grid] {
    user-select: none;
  }
  /* :global(::view-transition-new(header-f5744a65-5cd4-41d7-a3d9-5609e7ccefaf)) {
    animation: itemsLinkIn 0.3s;
  } */

  :global(::view-transition-group(*)) {
    animation-duration: 260ms;
    animation-timing-function: cubic-bezier(0.33, 1, 0.68, 1);
  }

  :global(::view-transition-old(*)),
  :global(::view-transition-new(*)) {
    mix-blend-mode: normal;
  }

  :global(::view-transition-old(root)) {
    animation: 250ms ease-in 0s fadeOut forwards;
    z-index: 1000;
  }
  :global(::view-transition-new(root)) {
    animation: 250ms ease-in 0s fadeIn forwards;
  }
  :global(::view-transition-old(info)) {
    animation: 250ms ease-in 0s flyOutRight forwards;
    z-index: 1000;
  }
  :global(::view-transition-new(info)) {
    animation: 250ms ease-in 0s flyInRight forwards;
  }
  :global(::view-transition-old(onTop)),
  :global(::view-transition-new(onTop)) {
    z-index: 1000000;
    animation: none;
  }

  :global(::view-transition-old(*)) {
    /* z-index: 10000; */
    animation: 350ms fadeOut;
  }
  :global(::view-transition-new(*)) {
    animation: 350ms fadeIn;
  }
  :global(::view-transition-old(good)) {
    z-index: 10000;
    animation: 350ms fadeIn;
    display: flex;
    align-content: center;
  }
  :global(::view-transition-new(good)) {
    animation: 350ms fadeIn;
    display: flex;
    align-content: center;
  }

  :global(::view-transition-old(next)) {
    /* z-index: 10000; */
    animation: 350ms flyOutLeft;
    transform-origin: center;
    height: 100%;
    object-fit: contain;
  }
  :global(::view-transition-new(next)) {
    animation: 350ms flyInRight;
    transform-origin: center;
    height: 100%;
    object-fit: contain;
  }

  :global(::view-transition-old(previous)) {
    /* z-index: 10000; */
    animation: 350ms flyOutRight;
    transform-origin: center;
    height: 100%;
    object-fit: contain;
  }
  :global(::view-transition-new(previous)) {
    animation: 350ms flyInLeft;
    transform-origin: center;
    height: 100%;
    object-fit: contain;
  }

  @keyframes -global-flyInLeft {
    from {
      transform: translateX(-100%);
      opacity: 0;
    }
    to {
      transform: translateX(0);
      opacity: 1;
    }
  }

  @keyframes -global-flyOutLeft {
    from {
      transform: translateX(0);
      opacity: 1;
    }
    to {
      transform: translateX(-100%);
      opacity: 0;
    }
  }

  @keyframes -global-flyInRight {
    from {
      transform: translateX(100%);
      opacity: 0;
    }
    to {
      transform: translateX(0);
      opacity: 1;
    }
  }

  /* Fly out to right */
  @keyframes -global-flyOutRight {
    from {
      transform: translateX(0);
      opacity: 1;
    }
    to {
      transform: translateX(100%);
      opacity: 0;
    }
  }

  @keyframes -global-fadeIn {
    from {
      opacity: 0;
    }
    to {
      opacity: 1;
    }
  }
  @keyframes -global-fadeOut {
    from {
      opacity: 1;
    }
    to {
      opacity: 0;
    }
  }
</style>
